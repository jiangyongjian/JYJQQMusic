//
//  JYJAudioTool.m
//  02-音效播放
//
//  Created by JYJ on 16/6/16.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJAudioTool.h"

@implementation JYJAudioTool

/**
 *  存放所有的音效ID
 */
static NSMutableDictionary *_soundIDs;
/**
 *  存放所有的音乐播放器
 */
static NSMutableDictionary *_musicPlayers;

//+ (NSMutableDictionary *)soundIDs{
//    if (!_soundIDs) {
//        _soundIDs = [NSMutableDictionary dictionary];
//    }
//    return _soundIDs;
//}

+ (void)initialize {
    // 音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 设置后台播放类别（播放类型、播放模式, 会自动停止其他音乐的播放）
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 激活会话
    [session setActive:YES error:nil];
    
    _soundIDs = [NSMutableDictionary dictionary];
    _musicPlayers = [NSMutableDictionary dictionary];
}



// 播放音乐 musicName : 音乐的名称
+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName {
    assert(musicName);
    if (!musicName) return nil;
    
    // 1.定义播放器
    AVAudioPlayer *player = _musicPlayers[musicName];
    if (!player) {
        // 2.音频文件的url
        NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
        
        if (!url) return nil;
        
        // 3.创建播放器(一个AVAudioPlayer只能播放一个URL)
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        // 4.缓冲
        if (![player prepareToPlay]) return nil;
        
        // 5.存入字典
        _musicPlayers[musicName] = player;
    }
    
    // 播放
    if (!player.isPlaying) {
        [player play];
    }
    
    // 正在播放
    return player;
}
// 暂停音乐 musicName : 音乐的名称
+ (void)pauseMusicWithMusicName:(NSString *)musicName {
    if (!musicName) return;
    
    // 1.取出对应的播放器
    AVAudioPlayer *player = _musicPlayers[musicName];
    
    // 2.暂停
    if (player.isPlaying) {
        [player pause];
    }
}
// 停止音乐 musicName : 音乐的名称
+ (void)stopMusicWithMusicName:(NSString *)musicName {
    if (!musicName) return;
    
    // 1.取出对应的播放器
    AVAudioPlayer *player = _musicPlayers[musicName];
    
    // 2.停止
    [player stop];
    
    // 3.将播放器从字典中移除
    [_musicPlayers removeObjectForKey:musicName];
}



/**
 *  播放音效
 *
 *  @param filename 音效的文件名
 */
+ (void)playSoundWithSoundName:(NSString *)soundName {
    if (!soundName) return;
    
    // 1.定义SystemSoundID
    SystemSoundID soundID = 0;
    
    // 2.从字典中取出对应soundID,如果取出是nil,表示之前没有存放在字典
    soundID = [_soundIDs[soundName] unsignedIntValue];
    if (soundID == 0) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        if (!url) return;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
        
        // 将soundID存放入字典
        [_soundIDs setObject:@(soundID) forKey:soundName];
    }
    // 播放音效
    AudioServicesPlaySystemSound(soundID);
}

/**
 *  销毁音效
 *
 *  @param filename 音效的文件名
 */
+ (void)disposeSound:(NSString *)filename
{
    if (!filename) return;
    
    // 1.取出对应的音效ID
    SystemSoundID soundID = [_soundIDs[filename] unsignedIntValue];
    
    // 2.销毁
    if (soundID) {
        AudioServicesDisposeSystemSoundID(soundID);
        
        [_soundIDs removeObjectForKey:filename];
    }
}


@end
