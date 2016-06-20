//
//  NSString+JYJTimeExtension.m
//  QQMusic
//
//  Created by JYJ on 16/6/16.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "NSString+JYJTimeExtension.h"

@implementation NSString (JYJTimeExtension)

+ (NSString *)stringWithTime:(NSTimeInterval)time
{
    NSInteger min = time / 60;
    NSInteger second = (NSInteger)time % 60;
    
    return [NSString stringWithFormat:@"%02ld:%02ld", min, second];
}


@end
