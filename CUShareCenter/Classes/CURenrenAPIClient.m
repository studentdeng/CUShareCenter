//
//  CURenrenAPIClient.m
//  Example
//
//  Created by curer on 13-10-30.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CURenrenAPIClient.h"

@implementation CURenrenAPIClient

+ (CUObjectManager *)shareObjectManager
{
    static dispatch_once_t pred = 0;
    __strong static CUObjectManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CUObjectManager alloc] init]; // or some other init method
        _sharedObject.baseURLString = @"https://api.renren.com/";
        [CURenrenAPIClient setup:_sharedObject];
    });
    
    return _sharedObject;
}

+ (void)setup:(CUObjectManager *)objectManager
{
    
}

@end
