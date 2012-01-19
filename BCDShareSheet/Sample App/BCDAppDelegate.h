//
//  BCDAppDelegate.h
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

#import <UIKit/UIKit.h>

/**
 An app to demonstrate how to use the BCDShareSheet framework.
 */
@class BCDViewController;

@interface BCDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BCDViewController *viewController;

@end
