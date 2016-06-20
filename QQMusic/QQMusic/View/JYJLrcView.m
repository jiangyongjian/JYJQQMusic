//
//  JYJLrcView.m
//  QQMusic
//
//  Created by JYJ on 16/6/17.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJLrcView.h"
#import "Masonry.h"
#import "JYJLrcTool.h"
#import "JYJLrcCell.h"
#import "JYJLrcline.h"
#import "JYJLrcLabel.h"
#import "JYJMusic.h"
#import "JYJMusicTool.h"
#import <MediaPlayer/MediaPlayer.h>


@interface JYJLrcView () <UITableViewDataSource>
/** tableView */
@property (nonatomic, strong) UITableView *tableView;
/** 歌词的数据 */
@property (nonatomic, strong) NSArray *lrclist;
/** 当前播放的歌词的下标 */
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation JYJLrcView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupTableView];
    }
    return self;
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.rowHeight = 35;
    [self addSubview:tableView];
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView = tableView;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
#warning scrollView设置约束比较麻烦，必须全部添加
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.width.equalTo(self.mas_width);
        make.right.equalTo(self.mas_right);
    }];
    
    // 设置tableView多出的滚动区域
    self.tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
#warning Xcode7.以后tableViewframe没有值的时候设置背景色是没有用的,所以你这句话在这里设置
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lrclist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYJLrcCell *cell = [JYJLrcCell cellWithTableView:tableView];
    
    if (self.currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:14];
        cell.lrcLabel.progress = 0;
    }
    
    
    // 2.给cell设置数据
    // 2.1取出模型
    JYJLrcline *lrcLine = self.lrclist[indexPath.row];
    // 2.2给cell设置数据
    cell.lrcLabel.text = lrcLine.text;
    return cell;
}


#pragma mark - 重写setCurrentTime方法
- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    
    // 用当前时间和歌词进行匹配
    NSInteger count = self.lrclist.count;
    for (int i = 0; i < count; i++) {
        // 1.拿到i位置的歌词
        JYJLrcline *currentLrcLine = self.lrclist[i];
        
        // 2.拿到下一句的歌词
        NSUInteger nextIndex = i + 1;
        JYJLrcline *nextLrcLine = nil;
        if (nextIndex < count) {
            nextLrcLine = self.lrclist[nextIndex];
        }
        
        // 3.用当前的时间和i位置的歌词进行比较，如果大于i位置的时间，并且小于下一句歌词的时间，那么显示当前的歌词
        if (self.currentIndex != i && currentTime >= currentLrcLine.time && currentTime < nextLrcLine.time) {

            // 1.获取需要刷新的行号
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            // 2.记录当前i的行号
            self.currentIndex = i;
            
            // 3.刷新当前的行,和上一行
            [self.tableView reloadRowsAtIndexPaths:@[indexPath, previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            // 4.显示对应这行的歌词
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            // 5.设置外界歌词的
            self.lrcLbabel.text = currentLrcLine.text;
            
            // 6.生成锁屏界面的图片
            [self generatorLockImage];
        }
        
        // 4.根据进度，显示label画多少
        if (self.currentIndex == i) {
            // 4.1拿出i位置的cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            JYJLrcCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // 4.2更新label的进度
            CGFloat progress = (currentTime - currentLrcLine.time) / (nextLrcLine.time - currentLrcLine.time);

            cell.lrcLabel.progress = progress;
            
            // 4.3设置外界歌词的label的进度
            self.lrcLbabel.progress = progress;
        }
        
    }
    
}

#pragma mark - 重写setLrcName方法
-(void)setLrcName:(NSString *)lrcName {
    
    // 0.重置保存的当前位置的下标
    self.currentIndex = 0;
    
    // 1.保存歌词名称
    _lrcName = [lrcName copy];
    
    // 2.解析歌词
    self.lrclist = [JYJLrcTool lrcToolWithLrcName:lrcName];
    
    // 3.刷新表格
    [self.tableView reloadData];
}

#pragma mark - 生成锁屏界面的图片
- (void)generatorLockImage {
    // 1.拿到当前歌曲的图片
    JYJMusic *playingMusic = [JYJMusicTool playingMusic];
    UIImage *currentImage = [UIImage imageNamed:playingMusic.icon];
    
    // 2.拿到三句歌词
    // 2.1获取当前的歌词
    JYJLrcline *currentLrc = self.lrclist[self.currentIndex];
    
    // 2.2获取上一句歌词
    NSInteger previousIndex = self.currentIndex - 1;
    JYJLrcline *previousLrc = nil;
    if (previousIndex >= 0) {
        previousLrc = self.lrclist[previousIndex];
    }
    
    // 2.3下一句歌词
    NSInteger nextIndex = self.currentIndex + 1;
    JYJLrcline *nextLrc = nil;
    if (nextIndex < self.lrclist.count) {
        nextLrc = self.lrclist[nextIndex];
    }
    
    // 3.生成水印图片
    // 3.1获取上下文
//    UIGraphicsBeginImageContext(currentImage.size);
    UIGraphicsBeginImageContextWithOptions(currentImage.size, NO, 0.0);
    // 3.2将图片画上去
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    
    // 3.3将歌词画到图片上
    CGFloat titleH = 25;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSParagraphStyleAttributeName : style};
    [previousLrc.text drawInRect:CGRectMake(0, currentImage.size.height - 3 * titleH, currentImage.size.width, titleH) withAttributes:attributes1];
    [nextLrc.text drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH) withAttributes:attributes1];
    
    NSDictionary *attributes2 = @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                  NSForegroundColorAttributeName : [UIColor yellowColor],
                                  NSParagraphStyleAttributeName : style};
    [currentLrc.text drawInRect:CGRectMake(0, currentImage.size.height - 2 * titleH, currentImage.size.width, titleH) withAttributes:attributes2];
    
    // 4.生成图片
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.设置锁屏信息
    [self setupLockScreenInfoWithLockImage:lockImage];
}

- (void)setupLockScreenInfoWithLockImage:(UIImage *)lockImage {
    // 0.获取当前正在播放的歌曲
    JYJMusic *playingMusic = [JYJMusicTool playingMusic];
    
    // 1.获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    playingInfo[MPMediaItemPropertyAlbumTitle] = playingMusic.name;
    playingInfo[MPMediaItemPropertyArtist] = playingMusic.singer;
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    playingInfo[MPMediaItemPropertyArtwork] = artwork;
    playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.currentTime);
    playingInfo[MPMediaItemPropertyPlaybackDuration] = @(self.duration);
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    
    // 3.让应用程序可以接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

@end
