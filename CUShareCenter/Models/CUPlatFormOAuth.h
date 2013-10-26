//
//  CUPlatFormOAuth.h
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUPlatFormOAuth : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSData *orginalData;

@end
