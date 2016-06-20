//
//  JYJLrcline.h
//  QQMusic
//
//  Created by JYJ on 16/6/17.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYJLrcline : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithLrclineString:(NSString *)lrclineString;
+ (instancetype)lrcLineWithLrclineString:(NSString *)lrclineString;
@end
