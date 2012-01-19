//
//  BCDAppDelegate.m
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

#import "BCDAppDelegate.h"
#import "BCDViewController.h"
#import "BCDShareSheet.h"

@implementation BCDAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[BCDViewController alloc] initWithNibName:@"BCDViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    BCDShareSheet *sharedSharer = [BCDShareSheet sharedSharer];
    [sharedSharer setAppName:@"Sample App"];
    [sharedSharer setRootViewController:self.viewController];
    [sharedSharer setFacebookAppID:@"123456789"]; // Replace with the ID of your Facebook app
                                                  // and ensure it matches the ID in the URL
                                                  // scheme in the Info.plist
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] hasPrefix:@"fb"]) {
        return [[BCDShareSheet sharedSharer] openURL:url];
    } else {
        return NO; // handle any other URLs your app responds to here.
    }
}

@end
