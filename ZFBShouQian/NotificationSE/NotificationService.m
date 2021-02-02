//
//  NotificationService.m
//  NotificationSE
//
//  Created by 李闯 on 2021/2/2.
//

#import "NotificationService.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "LCAudioPlayManager.h"

@interface NotificationService ()<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;


@property (nonatomic, strong) AVSpeechSynthesisVoice *synthesisVoice;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@end

@implementation NotificationService

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

- (void)serviceExtensionTimeWillExpire {
    NSLog(@"serviceExtensionTimeWillExpire");

    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}



- (AVSpeechSynthesisVoice *)synthesisVoice {
    if (!_synthesisVoice) {
        _synthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    }
    return _synthesisVoice;
}

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}
@end
