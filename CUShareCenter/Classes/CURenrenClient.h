//
//  CURenrenClient.h
//  Example
//
//  Created by curer on 13-10-30.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUShareCenter.h"
#import <RennSDK/RennSDK.h>

#import "PlatFormModel.h"
#import "CUPlatFormOAuth.h"
#import "CUPlatFormUserModel.h"
#import <CURestKit/CURestkit.h>

@interface CURenrenClient : NSObject <CUShareClientDataSource, RennLoginDelegate>

@end
