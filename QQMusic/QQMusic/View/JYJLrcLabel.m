//
//  JYJLrcLabel.m
//  QQMusic
//
//  Created by JYJ on 16/6/18.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJLrcLabel.h"

@implementation JYJLrcLabel
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 1.获取需要话的区域
    CGRect fillRect = CGRectMake(0, 0,self.progress * self.bounds.size.width, self.bounds.size.height);
    
    // 2.设置颜色
    [[UIColor redColor] set];
    
    // 3.添加区域
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}

@end
