//
//  CURenrenClient.m
//  Example
//
//  Created by curer on 13-10-30.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CURenrenClient.h"
#import "CUPlatFormUserModel.h"
#import "CURenrenAPIClient.h"

#import <RennSDK/RennSDK.h>
#import <RennSDK/RennAccessToken.h>

@interface CURenrenClient ()

@property (nonatomic, strong) ASIHTTPRequest *request;

@property (nonatomic, strong) void (^successBlock)(NSString *message, id data);
@property (nonatomic, strong) void (^failedBlock)( NSString *message, id data);

@end

@implementation CURenrenClient

+ (CURenrenClient *)sharedInstance:(PlatFormModel *)model
{
    static CURenrenClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CURenrenClient alloc] init];
        [_sharedInstance setupWithPlatForm:model];
    });
    
    return _sharedInstance;
}

- (void)setupWithPlatForm:(PlatFormModel *)model
{
    [RennClient initWithAppId:model.appId
                       apiKey:model.appKey
                    secretKey:model.appSecret];
    
    [RennClient setScope:@"read_user_album read_user_status publish_feed"];
    [RennClient setTokenType:@"bearer"];
}

- (id)initWithPlatForm:(PlatFormModel *)model
{
    //tencent qq 的sdk很奇怪，必须单例才能保证结果和预期一致，否则则会不经意的crash
    //而且他的demo也是单例，这个和我们最初的设计不符合，但是没有办法。太dt
    return [CURenrenClient sharedInstance:model];
}

#pragma mark - Bind/unBind

- (void)bindSuccess:(void (^)(NSString *message, id data))success error:(void (^)(NSString *message, id data))errorBlock
{
    self.successBlock = [success copy];
    self.failedBlock = [errorBlock copy];
    
    [RennClient loginWithDelegate:self];
}

- (void)unBind
{
    [RennClient logoutWithDelegate:nil];
}
- (BOOL)isBind;
{
    return [RennClient isAuthorizeValid];
}

#pragma mark - userInfo

- (CUPlatFormOAuth *)OAuthInfo
{
    if (![RennClient isAuthorizeValid]) {
        return nil;
    }
    
    CUPlatFormOAuth *info = [CUPlatFormOAuth new];
    info.accessToken = [RennClient accessToken].accessToken;
    info.userId = [RennClient uid];
    
    NSDictionary *dic = @{
                          @"accessToken" : [RennClient accessToken].accessToken,
                          @"expiresIn" : [NSNumber numberWithInteger:[RennClient accessToken].expiresIn]
                          };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:kNilOptions
                                                         error:nil];
    info.orginalData = jsonData;
    
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
    if (![RennClient isAuthorizeValid]) {
        return nil;
    }
    
    NSString *accessToken = [RennClient accessToken].accessToken;
    NSString *uid = [RennClient uid];
    
    NSAssert(accessToken, @"accessToken nil");
    NSAssert(uid, @"uid nil");
    
    ASIHTTPRequest *request =
    [[CURenrenAPIClient shareObjectManager] getJSONRequestAtPath:@"v2/user/get"
                                                      parameters:@{
                                                                   @"access_token" : accessToken,
                                                                   @"userId" : uid
                                                                   }
                                                         success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                             
                                                             id responseJSON = json[@"response"];
                                                           
                                                             CUPlatFormUserModel *model = [CUPlatFormUserModel new];
                                                             model.userId = uid;
                                                             model.nickname = responseJSON[@"name"];
                                                             model.avatar = responseJSON[@"avatar"][3][@"url"];
                                                             model.orginalData = responseJSON;
                                                           
                                                             success(model);
                                                           
                                                         } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                             errorBlock(ASIRequest.responseString);
                                                         }];
    return request;
}

#pragma mark - share

- (void)content:(NSString *)content
        success:(void (^)(id data))success
          error:(void (^)(id error))errorBlock
{
    NSAssert(FALSE, @"not implement ");
}

- (void)content:(NSString *)content
      imageData:(NSData *)imageData
        success:(void (^)(id data))success
          error:(void (^)(id error))errorBlock
{
    NSAssert(FALSE, @"not implement ");
}

- (void)content:(NSString *)content
       imageURL:(NSString *)imageURL
        success:(void (^)(id data))success
          error:(void (^)(id error))errorBlock
{
    NSAssert(FALSE, @"not implement ");
}

- (void)content:(NSString *)content
    description:(NSString *)description
          title:(NSString *)title
           link:(NSString *)link
       imageURL:(NSString *)imageURL
        success:(void (^)(id data))success
          error:(void (^)(id error))errorBlock
{
    NSString *accessToken = [RennClient accessToken].accessToken;
    
    [self.request clearDelegatesAndCancel];
    self.request =
    [[CURenrenAPIClient shareObjectManager] postJSONRequestAtPath:@"v2/feed/put"
                                                       parameters:@{
                                                                    @"access_token" : accessToken,
                                                                    @"description" : description,
                                                                    @"imageUrl" : imageURL,
                                                                    @"title" : title,
                                                                    @"targetUrl" : link,
                                                                    @"message" : content
                                                                    }
                                                          success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                              success(json);
                                                          } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                              errorBlock(errorMsg);
                                                          }];
    [self.request startAsynchronous];
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
    return [RennClient handleOpenURL:url];
}

#pragma mark - RennLoginDelegate

- (void)rennLoginSuccess
{
    void (^successBlock)(NSString *message, id data) = [self.successBlock copy];
    
    [self clear];
    
    if (successBlock) {
        successBlock(@"success", nil);
    }
}

- (void)rennLoginDidFailWithError:(NSError *)error;
{
    if (self.failedBlock) {
        self.failedBlock(@"error", nil);
    }
    
    [self clear];
}

- (void)rennLoginAccessTokenInvalidOrExpired:(NSError *)error
{
    if (self.failedBlock) {
        self.failedBlock(@"error", nil);
    }
    
    [self clear];
}

- (void)rennLoginCancelded
{
    if (self.failedBlock) {
        self.failedBlock(@"error", nil);
    }
    
    [self clear];
}

@end
