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
    [[CUShareCenter sharedInstance] connectSinaWeiboWithPlatForm:@"新浪微博"
                                                          AppKey:appKey
                                                       appSecret:appSecret
                                                     redirectUri:redirectUri];
}

//腾讯微博
+ (void)connectTencentWeiboWithAppKey:(NSString *)appKey
                            appSecret:(NSString *)appSecret
                          redirectUri:(NSString *)redirectUri
{
    [[CUShareCenter sharedInstance] connectSinaWeiboWithPlatForm:@"tencent.weibo"
                                                          AppKey:appKey
                                                       appSecret:appSecret
                                                     redirectUri:redirectUri];
}

//人人
+ (void)connectRenRenWithAppKey:(NSString *)appKey
                      appSecret:(NSString *)appSecret
                    redirectUri:(NSString *)redirectUri
{
    [[CUShareCenter sharedInstance] connectSinaWeiboWithPlatForm:@"renren"
                                                          AppKey:appKey
                                                       appSecret:appSecret
                                                     redirectUri:redirectUri];
}

+ (void)userInfoWithPlatForm:(NSString *)platForm
                     success:(void (^)(CUPlatFormUserModel *model))success
                       error:(void (^)(id data))errorBlock
{
    id<CUShareClientDataSource> client = [[CUShareCenter sharedInstance] clientWithPlatForm:platForm];
    [client userInfoSuccess:success error:errorBlock];
}

#pragma mark - Bind / Unbind

- (id<CUShareClientDataSource>)clientWithPlatForm:(NSString *)platForm
{
    if ([platForm isEqualToString:@"新浪微博"]) {
        PlatFormModel *model = [CUShareCenter sharedInstance].platFormDictionary[platForm];
        NSAssert(model, [platForm stringByAppendingString:@" did not found"]);
        CUSINAClient *client = [[CUSINAClient alloc] initWithPlatForm:model];
        
        return client;
    }
    
    return nil;
}

+ (id<CUShareClientDataSource>)bindWithPlatForm:(NSString *)platForm
                                      success:(void (^)(NSString *message, id data))success
                                        error:(void (^)(NSString *message, id data))errorBlock
{
    id<CUShareClientDataSource> client = [[CUShareCenter sharedInstance] clientWithPlatForm:platForm];
    [client bindSuccess:success error:errorBlock];
    return client;
}

+ (id<CUShareClientDataSource>)unBindWithPlatForm:(NSString *)platForm
{
    id<CUShareClientDataSource> client = [[CUShareCenter sharedInstance] clientWithPlatForm:platForm];
    [client unBind];
    return client;
}

#pragma mark - private

- (void)setup
{
    self.platFormDictionary = [NSMutableDictionary dictionary];
}

+ (void)registerDelegate:(id<CUShareCenterDelegate>)aDelegate
{
    
}

/*!
 */
- (void)connectSinaWeiboWithPlatForm:(NSString *)platForm
                              AppKey:(NSString *)appKey
                         appSecret:(NSString *)appSecret
                       redirectUri:(NSString *)redirectUri
{
    NSAssert(platForm.length, @"param error");
    NSAssert(appKey.length, @"param error");
    NSAssert(appSecret.length, @"param error");
    
    PlatFormModel *model = [PlatFormModel new];
    
    model.platForm = platForm;
    model.appKey = appKey;
    model.appSecret = appSecret;
    model.redirectUri = SAFE_STRING(redirectUri);
    
    
    [self.platFormDictionary setObject:model
                                forKey:platForm];
}

+ (void)platForm:(NSString *)platForm content:(NSString *)content success:(void (^)(id data))success
           error:(void (^)(id error))errorBlock
{
}

+ (void)platForm:(NSString *)platForm content:(NSString *)content imageData:(NSData *)imageData success:(void (^)(id data))success
           error:(void (^)(id error))errorBlock
{
}

+ (void)platForm:(NSString *)platForm content:(NSString *)content imageURL:(NSString *)imageURL success:(void (^)(id data))success
           error:(void (^)(id error))errorBlock
{
    
}

+ (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *platForm = nil;
    
    platForm = @"新浪微博";
    
    id<CUShareClientDataSource> client = [[CUShareCenter sharedInstance] clientWithPlatForm:platForm];
    return [client openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
