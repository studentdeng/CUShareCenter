//
//  SinaAPIClient.m
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUSinaAPIClient.h"
#import <CURestKit/CURestkit.h>

@implementation CUSinaAPIClient

+ (CUObjectManager *)shareObjectManager
{
    static dispatch_once_t pred = 0;
    __strong static CUObjectManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CUObjectManager alloc] init]; // or some other init method
        _sharedObject.baseURLString = @"https://api.weibo.com/";
        [CUSinaAPIClient setup:_sharedObject];
    });
    
    return _sharedObject;
}

+ (void)setup:(CUObjectManager *)objectManager
{
    
}

@end
