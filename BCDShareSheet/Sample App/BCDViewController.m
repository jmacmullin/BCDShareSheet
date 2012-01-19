//
//  BCDViewController.m
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

#import "BCDViewController.h"
#import "BCDShareSheet.h"
#import "BCDShareableItem.h"

@implementation BCDViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Interface Actions

- (IBAction)shareIt:(id)sender
{
    BCDShareableItem *item = [[BCDShareableItem alloc] initWithTitle:@"A cat in a cutlery rack"];
    [item setDescription:@"A cat in a cutlery rack, what more can I say?"];
    [item setItemURLString:@"http://icanhascheezburger.com/2011/11/21/funny-pictures-drainin-dah-catlery/"];
    [item setImageURLString:@"http://icanhascheezburger.files.wordpress.com/2011/11/funny-pictures-drainin-dah-catlery.jpg"];
    
    UIActionSheet *sheet = [[BCDShareSheet sharedSharer] sheetForSharing:item completion:^(BCDResult result) {
        if (result==BCDResultSuccess) {
            NSLog(@"Yay!");
        }
    }];
    [sheet showInView:self.view];
    [item release];
}

@end
