//
//  CUShareCenter.m
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUShareCenter.h"
#import "CUMacro.h"
#import "PlatFormModel.h"
#import "CUSINAClient.h"
#import "CUQQClient.h"
#import "CURenrenClient.h"

@interface CUShareCenter ()

@property (nonatomic, strong) NSMutableDictionary *platFormDictionary;

@end

@implementation CUShareCenter

+ (instancetype)sharedInstance {
    static CUShareCenter *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [CUShareCenter new];
        [_sharedInstance setup];
    });
    
    return _sharedInstance;
}

#pragma mark - public

/*!
 sina微博
 */
+ (void)connectSinaWeiboWithAppKey:(NSString *)appKey
                         appSecret:(NSString *)appSecret
                       redirectUri:(NSString *)redirectUri
{
    [[CUShareCenter sharedInstance] connectWithPlatForm:@"新浪微博"
                                                  AppId:nil
                                                 AppKey:appKey
                                              appSecret:appSecret
                                            redirectUri:redirectUri];
}


//腾讯QQ
+ (void)connectTencentQQWithAppID:(NSString *)appID
                           appKey:(NSString *)appKey
                      redirectUri:(NSString *)redirectUri
{
    [[CUShareCenter sharedInstance] connectWithPlatForm:@"QQ"
                                                  AppId:appID
                                                 AppKey:appKey
                                              appSecret:nil
                                            redirectUri:redirectUri];
}

//腾讯微博
+ (void)connectTencentWeiboWithAppKey:(NSString *)appKey
                            appSecret:(NSString *)appSecret
                          redirectUri:(NSString *)redirectUri
{
    [[CUShareCenter sharedInstance] connectWithPlatForm:@"tencent.weibo"
                                                  AppId:nil
                                                 AppKey:appKey
                                              appSecret:appSecret
                                            redirectUri:redirectUri];
}

//人人
+ (void)connectRenRenWithAppID:(NSString *)appId
                        AppKey:(NSString *)appKey
                     appSecret:(NSString *)appSecret
                   redirectUri:(NSString *)redirectUri;
{
    [[CUShareCenter sharedInstance] connectWithPlatForm:@"renren"
                                                  AppId:appId
                                                 AppKey:appKey
                                              appSecret:appSecret
                                            redirectUri:redirectUri];
}

+ (id<CUShareClientDataSource>)clientWithPlatForm:(NSString *)platForm
{
    return [[CUShareCenter sharedInstance] clientWithPlatForm:platForm];
}

#pragma mark - Bind / Unbind

- (id<CUShareClientDataSource>)clientWithPlatForm:(NSString *)platForm
{
    if ([platForm isEqualToString:@"新浪微博"]) {
        PlatFormModel *model = [CUShareCenter sharedInstance].platFormDictionary[platForm];
        NSAssert(model, [platForm stringByAppendingString:@" did not found"]);
        return [[CUSINAClient alloc] initWithPlatForm:model];
    }
    else if ([platForm isEqualToString:@"QQ"])
    {
        PlatFormModel *model = [CUShareCenter sharedInstance].platFormDictionary[platForm];
        NSAssert(model, [platForm stringByAppendingString:@" did not found"]);
        return [[CUQQClient alloc] initWithPlatForm:model];
    }
    else if ([platForm isEqualToString:@"renren"])
    {
        PlatFormModel *model = [CUShareCenter sharedInstance].platFormDictionary[platForm];
        NSAssert(model, [platForm stringByAppendingString:@" did not found"]);
        return [[CURenrenClient alloc] initWithPlatForm:model];
    }
    
    
    return nil;
}

#pragma mark - private

- (void)setup
{
    self.platFormDictionary = [NSMutableDictionary dictionary];
}

/*!
 */
- (void)connectWithPlatForm:(NSString *)platForm
                      AppId:(NSString *)appId
                     AppKey:(NSString *)appKey
                  appSecret:(NSString *)appSecret
                redirectUri:(NSString *)redirectUri
{
    PlatFormModel *model = [PlatFormModel new];
    
    model.platForm = SAFE_STRING(platForm);
    model.appKey = SAFE_STRING(appKey);
    model.appSecret = SAFE_STRING(appSecret);
    model.appId = SAFE_STRING(appId);
    model.redirectUri = SAFE_STRING(redirectUri);
    
    
    [self.platFormDictionary setObject:model
                                forKey:platForm];
}

+ (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *platForm = nil;
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        platForm = @"新浪微博";
    }
    else if ([sourceApplication isEqualToString:@"com.tencent.mqq"])
    {
        platForm = @"QQ";
    }
    
    if (platForm.length == 0) {
        return NO;
    }
    
    id<CUShareClientDataSource> client = [[CUShareCenter sharedInstance] clientWithPlatForm:platForm];
    return [client openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
