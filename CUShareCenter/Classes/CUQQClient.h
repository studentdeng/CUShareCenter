//
//  CUQQClient.h
//  Example
//
//  Created by curer on 13-10-27.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUShareCenter.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

@interface CUQQClient : NSObject <CUShareClientDataSource, TencentSessionDelegate>

@end
