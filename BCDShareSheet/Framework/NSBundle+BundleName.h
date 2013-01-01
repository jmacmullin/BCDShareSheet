//
//  NSBundle+BundleName.h
//  BCDShareSheet
//
//  Created by Simon B. Støvring on 01/01/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (BundleName)

/**
 *  Retrieve a bundle by its name.
 *  Orignally authored by Dale Zak.
 *  http://dalezak.ca/2012/12/nslocalizedstring-framework.html
 *  @param name Name of the bundle.
 *  @return Found bundle or nil if no bundle with the specified name exists.
 */
+ (NSBundle *)bundleWithName:(NSString *)name;

@end
