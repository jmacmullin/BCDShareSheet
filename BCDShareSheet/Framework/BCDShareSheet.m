//
//  BCDShareSheet.m
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

typedef enum {
	BCDEmailService,
    BCDFacebookService,
    BCDTwitterService
} BCDService;

NSString * const kEmailServiceTitle = @"Email";
NSString * const kFacebookServiceTitle = @"Facebook";
NSString * const kTwitterServiceTitle = @"Twitter";

NSString * const kTitleKey = @"title";
NSString * const kServiceKey = @"service";

NSString * const kFBAccessTokenKey = @"FBAccessTokenKey";
NSString * const kFBExpiryDateKey = @"FBExpirationDateKey";

#import <Twitter/Twitter.h>
#import "BCDShareSheet.h"
#import "BCDShareSheetMacros.h"

typedef void (^CompletionBlock)(BCDResult);

@interface BCDShareSheet()

@property (nonatomic, retain) BCDShareableItem *item; // the item that will be shared
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, retain) NSMutableArray *availableSharingServices; // services available for sharing
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic) BOOL waitingForFacebookAuthorisation;

- (void)determineAvailableSharingServices;

- (void)shareViaEmail;
- (void)shareViaFacebook;
- (void)shareViaTwitter;

// Facebook integration
- (void)initialiseFacebookIfNeeded;
- (BOOL)checkIfFacebookIsAuthorised;
- (void)showFacebookShareDialog;

@end


@implementation BCDShareSheet

@synthesize rootViewController = _rootViewController;
@synthesize facebookAppID = _facebookAppID;
@synthesize appName = _appName;
@synthesize hashTag = _hashTag;
@synthesize item = _item;
@synthesize completionBlock = _completionBlock;
@synthesize availableSharingServices = _availableSharingServices;
@synthesize facebook = _facebook;
@synthesize waitingForFacebookAuthorisation = _waitingForFacebookAuthorisation;

+ (BCDShareSheet *)sharedSharer {
    static BCDShareSheet *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    [self setItem:nil];
    [self setFacebook:nil];
    [self setFacebookAppID:nil];
    [self setRootViewController:nil];
    [self setCompletionBlock:nil];
    
#if !BCDSHARE_USE_ARC
    [super dealloc];
#endif
}

- (UIActionSheet *)sheetForSharing:(BCDShareableItem *)item completion:(void (^)(BCDResult))completionBlock {
    [self setItem:item];
    
    [self setCompletionBlock:completionBlock];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Share via"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    [self determineAvailableSharingServices];
    for (NSDictionary *serviceDictionary in self.availableSharingServices) {
        [sheet addButtonWithTitle:[serviceDictionary valueForKey:kTitleKey]];
    }
    
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"Cancel"]];
    
    BCDSHARE_AUTORELEASE(sheet);
    return sheet;
}

- (BOOL)openURL:(NSURL *)url {
    if ([[url absoluteString] hasPrefix:@"fb"]) {
        return [self.facebook handleOpenURL:url];
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        if (self.completionBlock!=nil) {
            self.completionBlock(BCDResultCancel);
        }
        return;
    }
    
    int selectedService = [[[self.availableSharingServices objectAtIndex:buttonIndex] valueForKey:kServiceKey] intValue];
    
    switch (selectedService) {
        case BCDEmailService:
            [self shareViaEmail];
            break;
            
        case BCDFacebookService:
            [self shareViaFacebook];
            break;
            
        case BCDTwitterService:
            [self shareViaTwitter];
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark MFMailComposeViewController Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self.rootViewController dismissModalViewControllerAnimated:YES];
    
    if (error!=nil) {
        if (self.completionBlock!=nil) {
            self.completionBlock(BCDResultFailure);
        }
    } else {
        if (self.completionBlock!=nil) {
            self.completionBlock(BCDResultSuccess);
        }
    }
}


#pragma mark -
#pragma mark FBSessionDelegate Methods

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:kFBAccessTokenKey];
    [defaults setObject:[self.facebook expirationDate] forKey:kFBExpiryDateKey];
    [defaults synchronize];
    
    if (self.waitingForFacebookAuthorisation == YES) {
        [self setWaitingForFacebookAuthorisation:NO];
        [self showFacebookShareDialog];
    }
}

#pragma mark -
#pragma mark Private Methods

- (void)determineAvailableSharingServices {
    if (self.availableSharingServices==nil) {
        
        NSMutableArray *services = [NSMutableArray array];
        
        // Check to see if email if available
        if ([MFMailComposeViewController canSendMail]) {
            NSDictionary *mailService = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:BCDEmailService], kServiceKey, 
                                         kEmailServiceTitle, kTitleKey,
                                         nil];
            [services addObject:mailService];
        }
        
        NSDictionary *facebookService = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:BCDFacebookService], kServiceKey, 
                                         kFacebookServiceTitle, kTitleKey,
                                         nil];
        [services addObject:facebookService];
        
        // Twitter is only available on iOS5 or later
        if([TWTweetComposeViewController class]) {
            NSDictionary *twitterService = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:BCDTwitterService], kServiceKey, 
                                            kTwitterServiceTitle, kTitleKey,
                                            nil];
            [services addObject:twitterService];
        }
        
        [self setAvailableSharingServices:services];
    }
}

#pragma mark - Email
- (void)shareViaEmail {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [mailComposeViewController setSubject:self.item.title];
    
    NSMutableString *body = [NSMutableString string];
    
    [body appendFormat:@"%@\n", self.item.title];
    if (self.item.itemURLString!=nil) {
        [body appendFormat:@"%@\n", self.item.itemURLString];
    }
    if (self.item.description!=nil) {
        [body appendFormat:@"%@", self.item.description];
    }
    
    if (self.appName!=nil) {        
        [body appendFormat:@"\n\nSent from %@", self.appName];
    }
    
    [mailComposeViewController setMessageBody:body isHTML:NO];
    [self.rootViewController presentModalViewController:mailComposeViewController animated:YES];
    BCDSHARE_RELEASE(mailComposeViewController);
}

#pragma mark - Facebook
- (void)shareViaFacebook {
    [self initialiseFacebookIfNeeded];
    
    BOOL isFacebookAuthorised = [self checkIfFacebookIsAuthorised];
    if (isFacebookAuthorised == YES) {
        // share
        [self showFacebookShareDialog];
    } else {
        // request authorisation
        // ask for 'offline access' so that the credentials don't
        // expire.
        NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", nil];
        [self.facebook authorize:permissions];
        [self setWaitingForFacebookAuthorisation:YES];
    }
}

- (void)initialiseFacebookIfNeeded {
    if (self.facebook == nil) {
        Facebook *facebook = [[Facebook alloc] initWithAppId:self.facebookAppID andDelegate:self];
        [self setFacebook:facebook];
        BCDSHARE_RELEASE(facebook);
    }
}

- (BOOL)checkIfFacebookIsAuthorised {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults valueForKey:kFBAccessTokenKey];
    NSDate *expirationDate = [defaults valueForKey:kFBExpiryDateKey];
    if (accessToken!=nil && expirationDate!=nil) {
        [self.facebook setAccessToken:accessToken];
        [self.facebook setExpirationDate:expirationDate];
    }
    
    return [self.facebook isSessionValid];
}

- (void)showFacebookShareDialog {    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.item.title!=nil) {
        [params setValue:self.item.title forKey:@"name"];
        [params setValue:self.item.title forKey:@"caption"];
    }
    if (self.item.imageURLString!=nil) {
        [params setValue:self.item.imageURLString forKey:@"picture"];
    }
    if (self.item.description!=nil) {
        [params setValue:self.item.description forKey:@"description"];
    }
    if (self.item.itemURLString!=nil) {
        [params setValue:self.item.itemURLString forKey:@"link"];
    }
    [self.facebook dialog:@"feed" andParams:params andDelegate:self];
}


#pragma mark - FaceBook Dialog Delegate

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    if (self.completionBlock!=nil) {
        self.completionBlock(BCDResultFailure);
    }
}

- (void)dialogDidComplete:(FBDialog *)dialog {
    if (self.completionBlock!=nil) {
        self.completionBlock(BCDResultSuccess);
    }
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    if (self.completionBlock!=nil) {
        self.completionBlock(BCDResultFailure);
    }
}


#pragma mark - Twitter

- (void)shareViaTwitter {
    
    NSMutableString *tweetText = [NSMutableString string];
    
    [tweetText appendString:self.item.title];
    
    if (self.item.shortDescription!=nil) {
        [tweetText appendFormat:@" - %@", self.item.shortDescription];
    }
    
    if (self.hashTag!=nil) {
        [tweetText appendFormat:@" #%@", self.hashTag];
    }
    
    TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:tweetText];
    [tweetComposeViewController addURL:[NSURL URLWithString:self.item.itemURLString]];
    [self.rootViewController presentModalViewController:tweetComposeViewController animated:YES];
    
    BCDSHARE_WEAK_IVAR BCDShareSheet *weakRef = self;
    [tweetComposeViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        switch (result) {
            case TWTweetComposeViewControllerResultDone:
                if (weakRef.completionBlock!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{            
                        weakRef.completionBlock(BCDResultSuccess);
                    });
                }
                break;
                
            default:
                if (weakRef.completionBlock!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{            
                        weakRef.completionBlock(BCDResultFailure);
                    });
                    
                }
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            [weakRef.rootViewController dismissViewControllerAnimated:NO completion:nil];
        });
    }];
    
    BCDSHARE_RELEASE(tweetComposeViewController);
}



@end
