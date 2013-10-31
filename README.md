CUShareCenter
=============

#介绍

分享组件

新浪 QQ	 RENREN2.0 认证分享

#example

1、

```objective-c
[CUShareCenter connectTencentQQWithAppID:@"100383099"
                                      appKey:@"4a9f17a08ed276a198de27ba58ff9b6d"
                                 redirectUri:@""];
                                 
```

2、

```objective-c
	id <CUShareClientDataSource> client = [CUShareCenter clientWithPlatForm:@"QQ"];
	
	//绑定登陆
	
	[client bindSuccess:^(NSString *message, id data) {
        NSLog(@"%@", message);
    } error:^(NSString *message, id data) {
        NSLog(@"%@", message);
    }];
    
    //分享
    [[CUShareCenter clientWithPlatForm:@"QQ"] content:@"test"
                                            imageData:imageData
                                              success:^(id data) {
                                                  NSLog(@"%@", data);
                                              } error:^(id error) {
                                                   NSLog(@"%@", error);
                                              }];
```
