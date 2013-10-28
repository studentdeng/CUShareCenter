//
//  CUQQAPIClient.h
//  Example
//
//  Created by curer on 13-10-28.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CURestKit/CURestkit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface CUQQAPIClient : NSObject

+ (CUObjectManager *)shareObjectManager;

+ (ASIHTTPRequest *)userInfoWithOAuth:(TencentOAuth *)oAuth
                              success:(void (^)(id json))success
                                error:(void (^)(NSString *errorMsg))errorBlock;

@end
