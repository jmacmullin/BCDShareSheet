//
//  BCDShareSheet.h
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

typedef enum {
	BCDResultSuccess,
    BCDResultFailure,
    BCDResultCancel
} BCDResult;

typedef enum {
	BCDEmailService = 1 << 0,
    BCDMessageService = 1 << 1,
    BCDFacebookService = 1 << 2,
    BCDTwitterService = 1 << 3
} BCDService;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Facebook.h"
#import "BCDShareableItem.h"

/**
 A common way of sharing stuff in different ways:
 - Email
 - Facebook
 - Twitter
 
 Use this class by obtaining a reference to the shared instance then configure it for your app.
 You'll need to provide a 'rootViewController' that can be used for presenting modal views (such
 as a mail compose view) and a Facebook App ID.
 */
@interface BCDShareSheet : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,
                                   FBSessionDelegate, FBDialogDelegate>

/**
 Obtain a reference to the shared instance of the BCDShareSheet. Don't try to use the sharer until 
 you've provided a 'rootViewController' and Facebook App ID though.
 */
+ (BCDShareSheet *)sharedSharer;


/**
 Get an action sheet you can present to the user to share the given item with the optional
 completion handler.
 */
- (UIActionSheet *)sheetForSharing:(BCDShareableItem *)item completion:(void (^)(BCDResult))completionBlock;

/**
 Some services (such as Facebook) require the app to be launched with a specific URL.
 This method gives the BCDShareSheet the chance to handle a launch URL. It'll return 'YES'
 if it has handled the URL, or 'NO' if it hasn't.
 */
- (BOOL)openURL:(NSURL *)url;

/**
 The root view controller that should be used for presenting
 other modal views (such as a mail compose view etc).
 */
@property (nonatomic, retain) UIViewController *rootViewController;

/**
 The Facebook App ID of the Facebook App you want to use to share stuff.
 */
@property (nonatomic, retain) NSString *facebookAppID;

/**
 The name of the app that you're sharing content from (will be included in an email signature).
 */
@property (nonatomic, retain) NSString *appName;

/**
 The hashtag you would like to add to any tweets sent via this sharer.
 */
@property (nonatomic, retain) NSString *hashTag;

/**
 Enabled services will be shown in the share dialog.
 */
@property (nonatomic, assign) BCDService services;

@end
