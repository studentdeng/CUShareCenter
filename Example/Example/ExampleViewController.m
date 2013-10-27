//
//  ExampleViewController.m
//  Example
//
//  Created by curer on 13-10-25.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "ExampleViewController.h"
#import "CUShareCenter.h"
#import "CUPlatFormUserModel.h"

@interface ExampleViewController ()

@property (nonatomic, strong) id<CUShareClientDataSource> sina;
@property (nonatomic, strong) id<CUShareClientDataSource> qq;

@end

@implementation ExampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [CUShareCenter connectSinaWeiboWithAppKey:@"1128481868"
                                    appSecret:@"024e9c1c0aca2d28c03f182e5924de67"
                                  redirectUri:@"http://112.124.12.104/network_analysis/index.php/sns/session?provider=weibo"];
    
    [CUShareCenter connectTencentQQWithAppKey:@"100383099"
                                    appSecret:@"b18665b1f77eb621e2e2403e4a4767ea"
                                  redirectUri:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)bindButtonClicked:(id)sender {
    self.sina = [CUShareCenter clientWithPlatForm:@"新浪微博"];
    [self.sina bindSuccess:^(NSString *message, id data) {
        NSLog(@"%@", message);
    } error:^(NSString *message, id data) {
        NSLog(@"%@", message);
    }];
}

- (IBAction)unBindButtonClicked:(id)sender {
    self.sina = [CUShareCenter clientWithPlatForm:@"新浪微博"];
    [self.sina unBind];
}

- (IBAction)userInfoButtonClicked:(id)sender {

    id <CUShareClientDataSource> client = [CUShareCenter clientWithPlatForm:@"新浪微博"];
    if ([client isBind]) {
        [client userInfoSuccess:^(CUPlatFormUserModel *model) {
            NSLog(@"%@", model.nickname);
        } error:^(id data) {
            NSLog(@"%@", data);
        }];
    }
    else
    {
        self.sina = [CUShareCenter clientWithPlatForm:@"新浪微博"];
        [self.sina bindSuccess:^(NSString *message, id data) {
            NSLog(@"%@", message);
        } error:^(NSString *message, id data) {
            NSLog(@"%@", message);
        }];
    }
}

- (IBAction)shareImageDataButtonClicked:(id)sender {
    id <CUShareClientDataSource> client = [CUShareCenter clientWithPlatForm:@"新浪微博"];
    if ([client isBind]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"gif"];
        NSData *imageData = [NSData dataWithContentsOfFile:path];
        
        [client content:@"test"
              imageData:imageData
                success:^(id data) {
                    NSLog(@"%@", data);
                } error:^(id error) {
                    NSLog(@"%@", error);
                }];
    }
    else
    {
        self.sina = [CUShareCenter clientWithPlatForm:@"新浪微博"];
        [self.sina bindSuccess:^(NSString *message, id data) {
            NSLog(@"%@", message);
        } error:^(NSString *message, id data) {
            NSLog(@"%@", message);
        }];
    }
}
- (IBAction)qqLoginButtonClicked:(id)sender {
    self.qq = [CUShareCenter clientWithPlatForm:@"QQ"];
    [self.qq bindSuccess:^(NSString *message, id data) {
        NSLog(@"%@", message);
    } error:^(NSString *message, id data) {
        NSLog(@"%@", message);
    }];
}
@end
