//
//  JYJLrcTool.m
//  QQMusic
//
//  Created by JYJ on 16/6/17.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJLrcTool.h"
#import "JYJLrcline.h"

@implementation JYJLrcTool
+ (NSArray *)lrcToolWithLrcName:(NSString *)lrcName {
    // 1.拿到歌词文件的路径
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:lrcName ofType:nil];
    
    // 2.读取歌词
    NSString *lrcSting = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    
    // 3.拿到歌词的数组
    NSArray *lrcArray = [lrcSting componentsSeparatedByString:@"\n"];
    
    // 4.遍历每一句歌词,转成模型
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *lrclineString in lrcArray) {
        // 拿到没一句歌词
        /*
         [ti:心碎了无痕]
         [ar:张学友]
         [al:]
         */
        // 过滤不需要的歌词的行
        if ([lrclineString hasPrefix:@"[ti:"] || [lrclineString hasPrefix:@"[ar:"] || [lrclineString hasPrefix:@"[al:"] || ![lrclineString hasPrefix:@"["]) {
            continue;
        }
        
        // 将歌词转成模型
        JYJLrcline *lrcline = [JYJLrcline lrcLineWithLrclineString:lrclineString];
        
        [tempArray addObject:lrcline];
    }
    return tempArray;
}
@end
