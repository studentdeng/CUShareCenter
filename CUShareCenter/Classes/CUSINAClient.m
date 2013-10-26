//
//  CUSINAClient.m
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUSINAClient.h"
#import "PlatFormModel.h"
#import "CUPlatFormOAuth.h"
#import "CUPlatFormUserModel.h"


#import <CURestKit/CURestkit.h>
#import "CUSinaAPIClient.h"

#define SINA_ACCESSTOKEN_KEY    @"com.sina.accessToken"
#define SINA_USERID_KEY         @"com.sina.uid"
#define SINA_EXPIRATIONDATE_KEY @"com.sina.expirationDate"


@interface CUSINAClient ()

@property (nonatomic, strong) SinaWeibo *sinaweiboSDK;
@property (nonatomic, strong) void (^successBlock)(NSString *message, id data);
@property (nonatomic, strong) void (^failedBlock)( NSString *message, id data);

@property (nonatomic, strong) ASIHTTPRequest *request;

@end

@implementation CUSINAClient

- (id)initWithPlatForm:(PlatFormModel *)model
{
    if (self = [super init]) {
        self.sinaweiboSDK = [[SinaWeibo alloc] initWithAppKey:model.appKey
                                                    appSecret:model.appSecret
                                               appRedirectURI:model.redirectUri
                                            ssoCallbackScheme:nil
                                                  andDelegate:self];
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESSTOKEN_KEY];
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USERID_KEY];
        NSDate *experationDate = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_EXPIRATIONDATE_KEY];
        
        if (accessToken != nil) {
            self.sinaweiboSDK.accessToken = accessToken;
            self.sinaweiboSDK.userID = uid;
            self.sinaweiboSDK.expirationDate = experationDate;
        }
    }
    
    return self;
}

- (void)bindSuccess:(void (^)(NSString *message, id data))success error:(void (^)(NSString *message, id data))errorBlock
{
    self.successBlock = [success copy];
    self.failedBlock = [errorBlock copy];
    [self.sinaweiboSDK logIn];
}

- (void)unBind
{
    self.successBlock = nil;
    self.failedBlock = nil;
    
    [self.sinaweiboSDK logOut];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_ACCESSTOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USERID_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_EXPIRATIONDATE_KEY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CUPlatFormOAuth *)OAuthInfo
{
    if (![self.sinaweiboSDK isAuthValid]) {
        return nil;
    }
    
    CUPlatFormOAuth *info = [CUPlatFormOAuth new];
    
    info.userId = self.sinaweiboSDK.userID;
    info.accessToken = self.sinaweiboSDK.accessToken;
    
    return info;
}

- (ASIHTTPRequest *)userInfoSuccess:(void (^)(CUPlatFormUserModel *model))success error:(void (^)(id data))errorBlock
{
    NSString *accessToken = self.sinaweiboSDK.accessToken;
    NSString *uid = self.sinaweiboSDK.userID;
    
    self.request =
    [[CUSinaAPIClient shareObjectManager] getJSONRequestAtPath:@"2/users/show.json"
                                                    parameters:@{
                                                                 @"access_token" : accessToken,
                                                                 @"uid" : uid
                                                                 }
                                                       success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                           
                                                           CUPlatFormUserModel *model = [CUPlatFormUserModel new];
                                                           model.userId = self.sinaweiboSDK.userID;
                                                           model.nickname = json[@"screen_name"];
                                                           model.avatar = json[@"avatar_hd"];
                                                           model.orginalData = json;
                                                           
                                                           success(model);
                                                           
                                                       } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                           errorBlock(ASIRequest.responseString);
                                                       }];
    
    [self.request startAsynchronous];
    
    return self.request;
}

- (void)clear
{
    self.sinaweiboSDK.delegate = nil;
    self.successBlock = nil;
    self.failedBlock = nil;
    
    [self.request clearDelegatesAndCancel];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([self.sinaweiboSDK isInstalled]) {
        self.sinaweiboSDK.ssoLoggingIn = YES;
    }
    
    return [self.sinaweiboSDK handleOpenURL:url];
}

/*!
 注册回调通知
 */
- (void)registerDelegate:(id<CUShareCenterDelegate>)aDelegate
{
}

/*!
 删除回调通知
 */
- (void)removeDelegate:(id<CUShareCenterDelegate>)aDelegate
{
}

#pragma mark - SinaWeiboDelegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [[NSUserDefaults standardUserDefaults] setObject:self.sinaweiboSDK.accessToken forKey:SINA_ACCESSTOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.sinaweiboSDK.userID forKey:SINA_USERID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.sinaweiboSDK.expirationDate forKey:SINA_EXPIRATIONDATE_KEY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.successBlock) {
        self.successBlock(@"success", nil);
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    if (self.successBlock) {
        self.successBlock(@"success", nil);
    }
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    if (self.failedBlock) {
        self.failedBlock(@"cancel", nil);
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    if (self.failedBlock) {
        self.failedBlock(@"error", nil);
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    if (self.failedBlock) {
        self.failedBlock(@"error", nil);
    }
}

@end
