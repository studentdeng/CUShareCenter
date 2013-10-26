//
//  CUShareClient.h
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CUShareClient;
@class PlatFormModel;
@protocol CUShareCenterDelegate <NSObject>

@optional
- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUShareSucceed:(CUShareClient *)client;
- (void)CUShareCancel:(CUShareClient *)client;

- (void)CUAuthSucceed:(CUShareClient *)client;
- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUNotifyLoginout:(CUShareClient *)client;

@end
