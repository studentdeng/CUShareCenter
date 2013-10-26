//
//  CUPlatFormUserModel.h
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUPlatFormUserModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatar;

@property (nonatomic, strong) NSData *orginalData;

@end
