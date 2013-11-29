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

#define NOTIFICATION_SINA_LOGIN_SUCCESS     @"CUSINAClient.login.success"
#define NOTIFICATION_SINA_LOGIN_FALIED      @"CUSINAClient.login.failed"


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
        
        [self refreshTokenFromDisk];
    }
    
    return self;
}

- (void)refreshTokenFromDisk
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESSTOKEN_KEY];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USERID_KEY];
    NSDate *experationDate = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_EXPIRATIONDATE_KEY];
    
    if (accessToken != nil) {
        self.sinaweiboSDK.accessToken = accessToken;
        self.sinaweiboSDK.userID = uid;
        self.sinaweiboSDK.expirationDate = experationDate;
    }
}

#pragma mark - Bind/unBind

- (void)bindSuccess:(void (^)(NSString *message, id data))success error:(void (^)(NSString *message, id data))errorBlock
{
    self.successBlock = [success copy];
    self.failedBlock = [errorBlock copy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoginNotification:)
                                                 name:NOTIFICATION_SINA_LOGIN_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoginNotification:)
                                                 name:NOTIFICATION_SINA_LOGIN_FALIED
                                               object:nil];
    
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

- (BOOL)isBind
{
    return [self.sinaweiboSDK isLoggedIn];
}

#pragma mark - userInfo

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

- (void)userInfoSuccess:(void (^)(CUPlatFormUserModel *model))success error:(void (^)(id data))errorBlock
{
    [self.request clearDelegatesAndCancel];
    self.request = [self requestUserInfoSuccess:success error:errorBlock];
    [self.request startAsynchronous];
}

- (ASIHTTPRequest *)requestUserInfoSuccess:(void (^)(CUPlatFormUserModel *model))success error:(void (^)(id data))errorBlock
{
    if (!self.sinaweiboSDK.isAuthValid) {
        return nil;
    }
    
    NSString *accessToken = self.sinaweiboSDK.accessToken;
    NSString *uid = self.sinaweiboSDK.userID;
    
    NSAssert(accessToken, @"accessToken nil");
    NSAssert(uid, @"uid nil");
    
    ASIHTTPRequest *request =
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
                                                           model.platform = @"新浪微博";
                                                           model.orginalData = json;
                                                           model.gender = json[@"gender"];
                                                           if ([model.gender isEqualToString:@"m"]) {
                                                               model.gender = @"男";
                                                           }
                                                           else
                                                           {
                                                               model.gender = @"女";
                                                           }
                                                           
                                                           success(model);
                                                           
                                                       } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                           errorBlock(ASIRequest.responseString);
                                                       }];
    return request;
}

#pragma mark - share

- (void)content:(NSString *)content success:(void (^)(id data))success
           error:(void (^)(id error))errorBlock
{
    [self.request clearDelegatesAndCancel];
    
    self.request = [self requestContent:content
                               imageURL:nil
                                success:^(id data) {
                                    
                                } error:^(id error) {
                                    
                                }];
}

- (void)content:(NSString *)content
      imageData:(NSData *)imageData
        success:(void (^)(id data))success
          error:(void (^)(id error))errorBlock
{
    [self.request clearDelegatesAndCancel];
    self.request = [self requestContent:content imageData:imageData success:success error:errorBlock];
    [self.request startAsynchronous];
}

- (void)content:(NSString *)content
       imageURL:(NSString *)imageURL
        success:(void (^)(id data))success
          error:(void (^)(id error))errorBlock
{
    [self.request clearDelegatesAndCancel];
    self.request = [self requestContent:content imageURL:imageURL success:success error:errorBlock];
    [self.request startAsynchronous];
}

- (ASIHTTPRequest *)requestContent:(NSString *)content
                          imageURL:(NSString *)imageURL
                           success:(void (^)(id data))success
                             error:(void (^)(id error))errorBlock
{
    NSAssert(FALSE, @"not @implement 新浪高级授权接口");
    return nil;
}

- (ASIHTTPRequest *)requestContent:(NSString *)content
                         imageData:(NSData *)imageData
                           success:(void (^)(id data))success
                             error:(void (^)(id error))errorBlock
{
    if (!self.sinaweiboSDK.isAuthValid) {
        return nil;
    }
    
    NSString *accessToken = self.sinaweiboSDK.accessToken;
    NSAssert(accessToken, @"accessToken nil");
    
    ASIHTTPRequest *request = [[CUSinaAPIClient shareObjectManager] postJSONRequestAtPath:@"2/statuses/upload.json"
                                                                                userBlock:^(ASIFormDataRequest *ASIRequest) {
                                                                                    [ASIRequest addPostValue:content forKey:@"status"];
                                                                                    [ASIRequest setPostValue:accessToken forKey:@"access_token"];
                                                                                    [ASIRequest addData:imageData forKey:@"pic"];
                                                                                    
                                                                                } success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                                                    success(json);
                                                                                } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                                                    errorBlock(errorMsg);
                                                                                }];
    
    return request;
}

- (void)clear
{
    self.sinaweiboSDK.delegate = nil;
    self.successBlock = nil;
    self.failedBlock = nil;
    
    [self.request clearDelegatesAndCancel];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([self.sinaweiboSDK isInstalled]) {
        self.sinaweiboSDK.ssoLoggingIn = YES;
    }
    
    return [self.sinaweiboSDK handleOpenURL:url];
}

#pragma mark - SinaWeiboDelegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [[NSUserDefaults standardUserDefaults] setObject:self.sinaweiboSDK.accessToken forKey:SINA_ACCESSTOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.sinaweiboSDK.userID forKey:SINA_USERID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.sinaweiboSDK.expirationDate forKey:SINA_EXPIRATIONDATE_KEY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SINA_LOGIN_SUCCESS
                                                        object:self];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SINA_LOGIN_FALIED
                                                        object:self];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SINA_LOGIN_FALIED
                                                        object:self];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SINA_LOGIN_FALIED
                                                        object:self];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    if (self.successBlock) {
        self.successBlock(@"success", nil);
    }
}

#pragma mark - notification

- (void)handleLoginNotification:(NSNotification *)notify
{
    NSString *name = notify.name;
    if ([name isEqualToString:NOTIFICATION_SINA_LOGIN_SUCCESS]) {
        
        void (^successBlock)(NSString *message, id data) = [self.successBlock copy];
        [self clear];
        
        [self refreshTokenFromDisk];
        
        if (successBlock) {
            successBlock(@"success", nil);
        }

    }
    else if ([name isEqualToString:NOTIFICATION_SINA_LOGIN_FALIED])
    {
        if (self.failedBlock) {
            self.failedBlock(@"error", nil);
        }
        
        [self clear];
    }
}

@end
