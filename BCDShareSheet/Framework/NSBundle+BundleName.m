//
//  NSBundle+BundleName.m
//  BCDShareSheet
//
//  Created by Simon B. Støvring on 01/01/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "NSBundle+BundleName.h"

@implementation NSBundle (BundleName)

// Orignally authored by Dale Zak.
// http://dalezak.ca/2012/12/nslocalizedstring-framework.html
+ (NSBundle *)bundleWithName:(NSString *)name
{
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:frameworkBundlePath])
    {
        return [NSBundle bundleWithPath:frameworkBundlePath];
    }
    
    return nil;
}

@end
