//
//  JYJLrcCell.m
//  QQMusic
//
//  Created by JYJ on 16/6/18.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJLrcCell.h"
#import "JYJLrcLabel.h"
#import "Masonry.h"

@interface JYJLrcCell ()

@end

@implementation JYJLrcCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"LrcCell";
    JYJLrcCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[JYJLrcCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        JYJLrcLabel *lrcLabel = [[JYJLrcLabel alloc] init];
        lrcLabel.textColor = [UIColor whiteColor];
        lrcLabel.font = [UIFont systemFontOfSize:14];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lrcLabel];
        _lrcLabel = lrcLabel;
        lrcLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}


@end
