//
//  BCDShareSheet.h
//  BCDShareSheet
//
//  Created by Bruno Wernimont on 10/05/12.
//  Copyright (c) 2012 Bruno Wernimont.
//

#define BCDSHARE_USE_ARC  __has_feature(objc_arc)
#define BCDSHARE_HAS_WEAK __has_feature(objc_arc_weak)

#if BCDSHARE_USE_ARC
    #define BCDSHARE_RETAIN(xx)
    #define BCDSHARE_RELEASE(xx)
    #define BCDSHARE_AUTORELEASE(xx)

    #if BK_HAS_WEAK
        #define BCDSHARE_WEAK_IVAR   __weak
    #else
        #define BCDSHARE_WEAK_IVAR   __unsafe_unretained
    #endif
#else
    #define BCDSHARE_RETAIN(xx)      [xx retain]
    #define BCDSHARE_RELEASE(xx)     [xx release]
    #define BCDSHARE_AUTORELEASE(xx) [xx autorelease]
    #define BCDSHARE_WEAK_IVAR
#endif