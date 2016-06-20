//
//  JYJMusicTool.m
//  QQMusic
//
//  Created by JYJ on 16/6/16.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJMusicTool.h"
#import "JYJMusic.h"
#import "MJExtension.h"

@implementation JYJMusicTool
static NSArray *_musics;
static JYJMusic *_playingMusic;



+ (void)initialize {
    if (!_musics) {
        _musics = [JYJMusic mj_objectArrayWithFilename:@"Musics.plist"];
    }
    
    if (_playingMusic == nil) {
        _playingMusic = _musics[1];
    }
}

/**
 *  返回所有的歌曲
 */
+ (NSArray *)musics {
    return _musics;
}

/**
 *  返回正在播放的歌曲
 */
+ (JYJMusic *)playingMusic {
    return _playingMusic;
}


+ (void)setPlayingMusic:(JYJMusic *)playingMusic {
    if (!playingMusic || ![_musics containsObject:playingMusic]) return;
    if (_playingMusic == playingMusic) return;
    
    _playingMusic = playingMusic;
}

/**
 *  下一首歌曲
 */
+ (JYJMusic *)nextMusic {
    // 1拿到当前播放歌词的下标
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.取出下一首
    NSInteger nextIndex = ++currentIndex;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    JYJMusic *nextMusic = _musics[nextIndex];
    
    return nextMusic;
}

/**
 *  上一首歌曲
 */
+ (JYJMusic *)previousMusic {
    // 1拿到当前播放歌词的下表
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.取出下一首
    NSInteger previousIndex = --currentIndex;
    if (previousIndex < 0) {
        previousIndex = _musics.count - 1;
    }
    JYJMusic *previousMusic = _musics[previousIndex];
    
    return previousMusic;
}
@end
