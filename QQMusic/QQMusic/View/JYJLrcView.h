//
//  JYJLrcView.h
//  QQMusic
//
//  Created by JYJ on 16/6/17.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JYJLrcLabel;
@interface JYJLrcView : UIScrollView

/** 当前播放的时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, copy) NSString *lrcName;

/** 外面的label */
@property (nonatomic, weak) JYJLrcLabel *lrcLbabel;

/** 当前歌曲的总时长 */
@property (nonatomic, assign) NSTimeInterval duration;
@end
