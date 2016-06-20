//
//  JYJPlayingViewController.m
//  QQMusic
//
//  Created by JYJ on 16/6/16.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "JYJPlayingViewController.h"
#import "Masonry.h"
#import "JYJAudioTool.h"
#import "JYJMusicTool.h"
#import "JYJMusic.h"
#import "NSString+JYJTimeExtension.h"
#import "CALayer+PauseAimate.h"
#import "JYJLrcView.h"
#import "JYJLrcLabel.h"

#define JYJColor(r,g,b) ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0])

@interface JYJPlayingViewController () <UIScrollViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

/** 歌词的view */
@property (weak, nonatomic) IBOutlet JYJLrcView *lrcView;
/** 歌词的Label */
@property (weak, nonatomic) IBOutlet JYJLrcLabel *lrcLabel;

/** 当前播放器 */
@property (nonatomic, weak) AVAudioPlayer *currentPlayer;

/** 进度的Timer */
@property (nonatomic, strong) NSTimer *progressTimer;

/** 歌词更新的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;


// 滑块
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
#pragma mark - slider的事件处理
- (IBAction)startSlide;
- (IBAction)sliderValueChange;
- (IBAction)endSlide;
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;

#pragma mark - 歌曲控制的事件处理
- (IBAction)playOrPause;
- (IBAction)previous;
- (IBAction)next;

@end

@implementation JYJPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 1.添加毛玻璃效果
    [self setupBlurView];
    
    // 2.设置滑块的图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    // 3.展示界面的信息
    [self startPlayingMusic];
    
    // 设置lrcView的contentSize
    NSLog(@"%f",self.view.bounds.size.width);
    self.lrcView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    self.lrcView.delegate = self;
    self.lrcView.lrcLbabel = self.lrcLabel;
    
    NSLog(@"%f",self.lrcView.contentSize.width);
    
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // 设置iconView圆角
    self.iconView.layer.cornerRadius = self.iconView.frame.size.width * 0.5;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderColor = JYJColor(36, 36, 36).CGColor;
    self.iconView.layer.borderWidth = 8;
}

- (void)setupBlurView {
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleBlack;
    [self.albumView addSubview:toolBar];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.albumView.mas_top);
//        make.bottom.equalTo(self.albumView.mas_bottom);
//        make.leading.equalTo(self.albumView.mas_leading);
//        make.trailing.equalTo(self.albumView.mas_trailing);
        
        make.edges.equalTo(self.albumView);
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 开始播放音乐
- (void)startPlayingMusic {
    // 1.取出当前播放的歌曲
    JYJMusic *playingMusic = [JYJMusicTool playingMusic];
    
    // 2.设置界面信息
    self.albumView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.singerLabel.text = playingMusic.singer;
    
    // 3.开始播放歌曲
    AVAudioPlayer *currentPlayer = [JYJAudioTool playMusicWithMusicName:playingMusic.filename];
    currentPlayer.delegate = self;
    self.totalTimeLabel.text = [NSString stringWithTime:currentPlayer.duration] ;
    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    self.currentPlayer = currentPlayer;
    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
    
    // 4.设置歌词
    self.lrcView.lrcName = playingMusic.lrcname;
    //刚开始 外界歌词label清空
    self.lrcLabel.text = @"";
    
    self.lrcView.duration = currentPlayer.duration;
    
    // 5.开始播放动画
    [self startIconViewAnimate];
    
    // 6.添加定时器用户更新进度界面
    [self removeProgressTimer];
    [self addProgressTimer];
    [self removeLrcTimer];
    [self addLrcTimer];
}

/**
 *  开始播放动画
 */
- (void)startIconViewAnimate {
    // 1.创建基本动画
    CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 2.设置基本动画属性
    rotateAnim.fromValue = @(0);
    rotateAnim.toValue = @(M_PI * 2);
    rotateAnim.repeatCount = NSIntegerMax;
    rotateAnim.duration = 40;
    
    // 3.添加动画到图层上
    [self.iconView.layer addAnimation:rotateAnim forKey:nil];
}

#pragma mark - 对定时器的操作
- (void)addProgressTimer {
    [self updateProgressInfo];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
//    self.progressTimer = progressTimer;
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)addLrcTimer {
    CADisplayLink *lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    self.lrcTimer = lrcTimer;
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer {
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

#pragma mark - 用户更新经度界面
- (void)updateProgressInfo {
    // 1.设置当前的播放时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 2.更新滑块的位置
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}

#pragma mark - 更新歌词
- (void)updateLrc {
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}


#pragma mark - Slider的事件处理
- (IBAction)startSlide {
    [self removeProgressTimer];
}

- (IBAction)sliderValueChange {
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.duration * self.progressSlider.value];
}

- (IBAction)endSlide {
    // 1.设置歌曲的播放时间
    self.currentPlayer.currentTime = self.currentPlayer.duration * self.progressSlider.value;
    // 2. 添加定时器
    [self addProgressTimer];
    
}

- (IBAction)sliderClick:(UITapGestureRecognizer *)sender {
    // 1.获取点击的位置
    CGPoint point = [sender locationInView:self.progressSlider];
    
    // 2.获取点击的slider长度中占据的比例
    CGFloat ratio = point.x / self.progressSlider.bounds.size.width;
    
    // 3.更改歌曲的播放时间
    self.currentPlayer.currentTime = self.currentPlayer.duration * ratio;
    
    // 4.跟新经度信息
//    [self updateProgressInfo];
    [self removeProgressTimer];
    [self addProgressTimer];
}

/**
 *  开始或暂停
 */
- (IBAction)playOrPause {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.selected;
    
    if (self.currentPlayer.isPlaying) {
        [self.currentPlayer pause];
        
        // 移除所有的定时器
        [self removeProgressTimer];
        [self removeLrcTimer];
        
        // 暂停iconView的动画
        [self.iconView.layer pauseAnimate];
    } else {
        [self.currentPlayer play];
        
        // 添加定时器
        [self addProgressTimer];
        [self addLrcTimer];
        
        // 回复iconView的动画
        [self.iconView.layer resumeAnimate];
    }
}
/**
 *  上一首
 */
- (IBAction)previous {
    // 1.取出上一首歌曲
    JYJMusic *previousMusic = [JYJMusicTool previousMusic];
    
    // 2.播放上一首歌曲
    [self playingMusicWithMusic:previousMusic];
}
/**
 *  下一首
 */
- (IBAction)next {
    // 1.取出下一首歌曲
    JYJMusic *nextMusic = [JYJMusicTool nextMusic];
    
    // 2.播放上一首歌曲
    [self playingMusicWithMusic:nextMusic];
}


- (void)playingMusicWithMusic:(JYJMusic *)music {
    // 1.停止当前歌曲
    JYJMusic *palyingMusic = [JYJMusicTool playingMusic];
    [JYJAudioTool stopMusicWithMusicName:palyingMusic.filename];

    // 3.播放歌曲
    [JYJAudioTool playMusicWithMusicName:music.filename];

    // 4.将工具尅中的当前歌曲切换成播放的歌曲
    [JYJMusicTool setPlayingMusic:music];

    // 5.更改界面信息
    [self startPlayingMusic];
}

#pragma mark - 实现UIScrollView的代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1.获取到滑动多少
    CGPoint point = scrollView.contentOffset;
    
    // 2.计算滑动的比例
    CGFloat ratio = 1 - point.x / scrollView.bounds.size.width;
    
    // 3.设置iconView和歌词的label的透明度
    self.iconView.alpha = ratio;
    self.lrcLabel.alpha = ratio;
}

#pragma mark - AVAudioplayer的代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self next];
    }
}


// 监听远程事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
