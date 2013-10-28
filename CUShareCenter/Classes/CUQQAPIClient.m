//
//  CUQQAPIClient.m
//  Example
//
//  Created by curer on 13-10-28.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUQQAPIClient.h"

@implementation CUQQAPIClient

+ (CUObjectManager *)shareObjectManager
{
    static dispatch_once_t pred = 0;
    __strong static CUObjectManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CUObjectManager alloc] init]; // or some other init method
        _sharedObject.baseURLString = @"https://graph.qq.com/";
        [CUQQAPIClient setup:_sharedObject];
    });
    
    return _sharedObject;
}

+ (void)setup:(CUObjectManager *)objectManager
{
    
}

+ (ASIHTTPRequest *)userInfoWithOAuth:(TencentOAuth *)oAuth
                              success:(void (^)(id json))success
                                error:(void (^)(NSString *errorMsg))errorBlock;
{
    ASIHTTPRequest *request =
    [[CUQQAPIClient shareObjectManager] getJSONRequestAtPath:@"user/get_user_info"
                                                  parameters:@{
                                                               @"access_token" : oAuth.accessToken,
                                                               @"openid" : oAuth.openId,
                                                               @"oauth_consumer_key" : oAuth.appId,
                                                               @"format" : @"json"
                                                               }
                                                     success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                         success(json);
                                                     } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                         errorBlock(errorMsg);
                                                     }];
    
    return request;
}

+ (ASIHTTPRequest *)postContent:(NSString *)content
                          OAuth:(TencentOAuth *)oAuth
                        success:(void (^)(id json))success
                          error:(void (^)(NSString *errorMsg))errorBlock
{
    ASIHTTPRequest *request =
    
    [[CUQQAPIClient shareObjectManager] postJSONRequestAtPath:@"t/add_t"
                                                   parameters:@{
                                                                @"access_token" : oAuth.accessToken,
                                                                @"openid" : oAuth.openId,
                                                                @"oauth_consumer_key" : oAuth.appId,
                                                                @"format" : @"json",
                                                                @"content" : content
                                                                }
                                                      success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                          success(json);
                                                      } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                          errorBlock(errorMsg);
                                                      }];
    return request;
}

+ (ASIHTTPRequest *)postContent:(NSString *)content
                      ImageData:(NSData *)imageData
                          OAuth:(TencentOAuth *)oAuth
                        success:(void (^)(id json))success
                          error:(void (^)(NSString *errorMsg))errorBlock
{
    ASIHTTPRequest *request =
    [[CUQQAPIClient shareObjectManager] postJSONRequestAtPath:@"t/add_pic_t"
                                                    userBlock:^(ASIFormDataRequest *ASIRequest) {
                                                        
                                                        [ASIRequest addPostValue:oAuth.accessToken forKey:@"access_token"];
                                                        [ASIRequest addPostValue:oAuth.openId forKey:@"openid"];
                                                        [ASIRequest addPostValue:oAuth.appId forKey:@"oauth_consumer_key"];
                                                        [ASIRequest addPostValue:@"json" forKey:@"format"];
                                                        
                                                        [ASIRequest addPostValue:content forKey:@"content"];
                                                        [ASIRequest addData:imageData forKey:@"pic"];
                                                        
                                                    } success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                        success(json);
                                                    } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                        errorBlock(errorMsg);
                                                    }];
    
    return request;
}

@end
