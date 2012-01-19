//
//  BCDShareableItem.h
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

#import <Foundation/Foundation.h>

/**
 Something you want to share via email, Facebook, Twitter etc.
 */
@interface BCDShareableItem : NSObject

/**
 The title of the thing you're sharing.
 */
@property (nonatomic, retain) NSString *title;

/**
 A short description of the thing you're sharing. This will be used in combination
 with the tile and any hashtag in Tweets so please keep it short.
 */
@property (nonatomic, retain) NSString *shortDescription;

/**
 A more detailed description of the thing you're sharing. This can be long and will only be used
 in emails or posts to Facebook.
 */
@property (nonatomic, retain) NSString *description;

/**
 A String containing an absolute URL to an image relevent to the thing you're sharing.
 */
@property (nonatomic, retain) NSString *imageURLString;

/**
 A String containing an absolute URL to the thing you're sharing.
 */
@property (nonatomic, retain) NSString *itemURLString;

/**
 The designated initialiser. Initialises a shareable item with a title (which is required for all shareable items).
 */
- (id)initWithTitle:(NSString *)title;

@end
