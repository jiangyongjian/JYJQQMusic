//
//  JYJMusicTool.h
//  QQMusic
//
//  Created by JYJ on 16/6/16.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JYJMusic;
@interface JYJMusicTool : NSObject

/**
 *  返回所有的歌曲
 */
+ (NSArray *)musics;

/**
 *  返回正在播放的歌曲
 */
+ (JYJMusic *)playingMusic;
+ (void)setPlayingMusic:(JYJMusic *)playingMusic;

/**
 *  下一首歌曲
 */
+ (JYJMusic *)nextMusic;

/**
 *  上一首歌曲
 */
+ (JYJMusic *)previousMusic;

@end
