//
//  JYJLrcline.m
//  QQMusic
//
//  Created by JYJ on 16/6/17.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJLrcline.h"

@implementation JYJLrcline

- (instancetype)initWithLrclineString:(NSString *)lrclineString {
    if (self = [super init]) {
        // [00:02.34]作词：刘兵
        NSArray *lrcArray = [lrclineString componentsSeparatedByString:@"]"];
        self.text = lrcArray[1];
        NSString *timeString = lrcArray[0];
        self.time = [self timeStringWithString:[timeString substringFromIndex:1]];
    }
    return self;
}
+ (instancetype)lrcLineWithLrclineString:(NSString *)lrclineString {
    return [[self alloc] initWithLrclineString:lrclineString];
}


#pragma mark - 私有方法
- (NSTimeInterval )timeStringWithString:(NSString *)timeString {
    // 00:02.34
    NSInteger min = [[[timeString componentsSeparatedByString:@":"] firstObject] integerValue];
    NSInteger second = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSUInteger haomiao = [[[timeString componentsSeparatedByString:@"."] lastObject] integerValue];
    return (min * 60 + second + haomiao * 0.01);
}

@end
