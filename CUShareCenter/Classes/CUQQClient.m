//
//  CUQQClient.m
//  Example
//
//  Created by curer on 13-10-27.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUQQClient.h"
#import "PlatFormModel.h"
#import "CUPlatFormOAuth.h"
#import "CUPlatFormUserModel.h"
#import <CURestKit/CURestkit.h>

#define QQ_ACCESSTOKEN_KEY    @"com.tencent.QQ.accessToken"
#define QQ_USERID_KEY         @"com.tencent.QQ.uid"
#define QQ_EXPIRATIONDATE_KEY @"com.tencent.QQ.expirationDate"

#define NOTIFICATION_QQ_LOGIN_SUCCESS     @"CUQQClient.login.success"
#define NOTIFICATION_QQ_LOGIN_FALIED      @"CUQQClient.login.failed"

@interface CUQQClient ()

@property (nonatomic, strong) TencentOAuth *qqOAuthSDK;
@property (nonatomic, strong) void (^successBlock)(NSString *message, id data);
@property (nonatomic, strong) void (^failedBlock)( NSString *message, id data);

@property (nonatomic, strong) ASIHTTPRequest *request;

@end

@implementation CUQQClient

- (id)initWithPlatForm:(PlatFormModel *)model
{
    if (self = [super init]) {
        self.qqOAuthSDK = [[TencentOAuth alloc] initWithAppId:model.appKey
                                                  andDelegate:self];
        if (model.redirectUri.length > 0) {
            self.qqOAuthSDK.redirectURI = model.redirectUri;
        }
        
//        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:QQ_ACCESSTOKEN_KEY];
//        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:QQA_USERID_KEY];
//        NSDate *experationDate = [[NSUserDefaults standardUserDefaults] objectForKey:QQ_EXPIRATIONDATE_KEY];
//        
//        if (accessToken != nil) {
//            self.sinaweiboSDK.accessToken = accessToken;
//            self.sinaweiboSDK.userID = uid;
//            self.sinaweiboSDK.expirationDate = experationDate;
//        }
    }
    
    return self;
}

#pragma mark - Bind/unBind

- (void)bindSuccess:(void (^)(NSString *message, id data))success error:(void (^)(NSString *message, id data))errorBlock
{
    self.successBlock = [success copy];
    self.failedBlock = [errorBlock copy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoginNotification:)
                                                 name:NOTIFICATION_QQ_LOGIN_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoginNotification:)
                                                 name:NOTIFICATION_QQ_LOGIN_FALIED
                                               object:nil];
    
    [self.qqOAuthSDK authorize:@[@"get_user_info", @"add_t"]
                      inSafari:YES];
}

- (void)clear
{
    self.successBlock = nil;
    self.failedBlock = nil;
    
    [self.request clearDelegatesAndCancel];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [TencentOAuth HandleOpenURL:url];
}

#pragma mark - QQSDKDelegate

- (void)tencentDidLogin
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_QQ_LOGIN_SUCCESS
//                                                        object:self];
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_QQ_LOGIN_FALIED
                                                        object:self];
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_QQ_LOGIN_FALIED
                                                        object:self];
}

/**
 * 请求获得内容 当前版本只支持第三方相应腾讯业务请求
 */
- (BOOL)onTencentReq:(TencentApiReq *)req
{
    return YES;
}

/**
 * 响应请求答复 当前版本只支持腾讯业务相应第三方的请求答复
 */
- (BOOL)onTencentResp:(TencentApiResp *)resp
{
    return YES;
}

#pragma mark - notification

- (void)handleLoginNotification:(NSNotification *)notify
{
    NSString *name = notify.name;
    if ([name isEqualToString:NOTIFICATION_QQ_LOGIN_SUCCESS]) {
        
        if (self.successBlock) {
            self.successBlock(@"success", nil);
        }
        
        [self clear];
    }
    else if ([name isEqualToString:NOTIFICATION_QQ_LOGIN_FALIED])
    {
        if (self.failedBlock) {
            self.failedBlock(@"error", nil);
        }
        
        [self clear];
    }
}

@end
