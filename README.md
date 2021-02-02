# ZFBShouQian

文章地址：[https://blog.csdn.net/tianzhilan0/article/details/113569951](https://blog.csdn.net/tianzhilan0/article/details/113569951)


### 需求
1、实现类似支付宝收钱时语音播报

### 实现思路
1、集成极光推送
2、使用tts将金额播报出来（iOS10至iOS12）
3、收到推送后，处理金额，奖金额分割转换成一个个音频文件
4、将金额以本地推送形式，自定义语音播放出来

### 实现步骤
#### 1、项目配置
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202175738908.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3RpYW56aGlsYW4w,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202175829834.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3RpYW56aGlsYW4w,size_16,color_FFFFFF,t_70)


![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202175711435.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3RpYW56aGlsYW4w,size_16,color_FFFFFF,t_70)
#### 2、集成极光
- Cocoapods集成极光
```bash
    pod 'JCore'
    pod 'JPush'
```

- 在AppDelegate里面配置
```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化极光
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    [JPUSHService setupWithOption:launchOptions appKey:@"16185342a0cf0e7ada842c78"
                          channel:@"0"
                 apsForProduction:NO
            advertisingIdentifier:nil];
    
    return YES;
}
```
- JPUSHRegisterDelegate出来
```objectivec
#pragma mark - JPUSHRegisterDelegate

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
    
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    NSLog(@"%@", response.notification);
    //完成回调
    completionHandler();
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    
    NSLog(@"%@", notification);

}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  /// 注册 DeviceToken
  [JPUSHService registerDeviceToken:deviceToken];
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    
}
```

#### 3、NotificationService
- 导入音频文件（不支持网络文件）
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202180323809.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3RpYW56aGlsYW4w,size_16,color_FFFFFF,t_70)
- NotificationService.m

```objectivec
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    
    NSLog(@"接到通知 NotificationService");
    
    NSDictionary *info = self.bestAttemptContent.userInfo;
    NSLog(@"info ==> %@", info);
    
    //step1: 推送json解析,获取推送金额
    NSMutableDictionary *dict = [self.bestAttemptContent.userInfo mutableCopy] ;
    BOOL playaudio =  [[dict objectForKey:@"amount"] boolValue] ;
    if(playaudio) {
        
        //step2:先处理金额，得到语音文件的数组,并播放语音(本地推送 -音频)
        NSString *amount = [dict objectForKey:@"amount"] ;//10000
        NSArray *musicArr = [[LCAudioPlayManager sharedInstance] getMusicArrayWithNum:amount];
        __weak __typeof(self) weakSelf = self;
        [[LCAudioPlayManager sharedInstance] pushLocalNotificationToApp:0 withArray:musicArr completed:^{
            // 播放完成后，通知系统
            weakSelf.contentHandler(weakSelf.bestAttemptContent);
        }];
        
    } else {
        //系统通知
        self.contentHandler(self.bestAttemptContent);
    }
}
```

#### 4、项目运行
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202180724958.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3RpYW56aGlsYW4w,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202180836654.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3RpYW56aGlsYW4w,size_16,color_FFFFFF,t_70)

