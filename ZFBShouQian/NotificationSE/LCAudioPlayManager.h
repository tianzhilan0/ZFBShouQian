//
//  LCAudioPlayManager.h
//  NotificationSE
//
//  Created by 李闯 on 2021/2/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 处理完成的callback
typedef void (^LCNotificationPushCompleted)(void);
@interface LCAudioPlayManager : NSObject

+ (instancetype)sharedInstance;

// 先处理金额，得到语音文件的数组
-(NSArray *)getMusicArrayWithNum:(NSString *)numStr;

// 循环调用本地通知,播放音频文件
-(void)pushLocalNotificationToApp:(NSInteger)index withArray:(NSArray *)tmparray completed:(LCNotificationPushCompleted)completed;

/// 系统的语音播报(红包消息)
/// @param numStr <#numStr description#>
/// AVSpeechSynthesizer(iOS10.0-12.0),之后不支持播报
- (void)speechWalllentMessage:(NSString *)numStr;

@end

NS_ASSUME_NONNULL_END
