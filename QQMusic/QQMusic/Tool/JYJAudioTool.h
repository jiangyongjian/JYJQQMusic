//
//  JYJAudioTool.h
//  02-音效播放
//
//  Created by JYJ on 16/6/16.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface JYJAudioTool : NSObject

#pragma mark - 音效播放
// 播放声音文件soundName : 音效文件的名称
+ (void)playSoundWithSoundName:(NSString *)soundName;
// 销毁音效 filename 音效的文件名
+ (void)disposeSound:(NSString *)filename;

#pragma mark - 播放音乐
// 播放音乐 musicName : 音乐的名称
+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName;
// 暂停音乐 musicName : 音乐的名称
+ (void)pauseMusicWithMusicName:(NSString *)musicName;
// 停止音乐 musicName : 音乐的名称
+ (void)stopMusicWithMusicName:(NSString *)musicName;

@end
