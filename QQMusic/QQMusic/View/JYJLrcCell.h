//
//  JYJLrcCell.h
//  QQMusic
//
//  Created by JYJ on 16/6/18.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JYJLrcLabel;

@interface JYJLrcCell : UITableViewCell

/** 外界传进来想显示什么样的cell */
@property (nonatomic, weak, readonly) JYJLrcLabel *lrcLabel;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
