//
//  NTESLDView.m
//  NTESLiveDetectPublicDemo
//
//  Created by Ke Xu on 2019/10/14.
//  Copyright © 2019 Ke Xu. All rights reserved.
//

#import "NTESLiveDetectView.h"
#import <Masonry.h>
#import "LDDemoDefines.h"
#import "UIImageView+NTESLDGif.h"
#import <AVFoundation/AVFoundation.h>

@interface NTESLiveDetectView ()

@property (nonatomic, strong) UIButton *voiceButton;

@property (nonatomic, strong) UIButton *backBarButton;

@property (nonatomic, strong) UILabel *actionsText;

@property (nonatomic, strong) UIImageView *frontImage;

@property (nonatomic, strong) UIImageView *actionImage;

@property (nonatomic, strong) UIView *actionIndexView;

// 已完成的动作个数
@property (nonatomic, assign) NSUInteger actionsCount;

// 动图数组
@property (nonatomic, copy) NSArray *imageArray;

// 音频数组
@property (nonatomic, copy) NSArray *musicArray;

// 动作序列
@property (nonatomic, copy) NSString *actions;

// 底部进度标识view组
@property (nonatomic, copy) NSArray *indexViewArray;

// 底部进度标识左边距
@property (nonatomic, assign) CGFloat leftPadding;

// 音频播放组件
@property (nonatomic, strong) AVAudioPlayer *player;

// 播放状态：是否要播放
@property (nonatomic, assign) BOOL shouldPlay;

@end

@implementation NTESLiveDetectView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.actionsCount = 0;
        self.shouldPlay = YES;
        self.imageArray = @[@"", @"turn-right", @"turn-left", @"open-mouth", @"open-eyes"];
        self.musicArray = @[@"", @"turn-right", @"turn-left", @"open-mouth", @"open-eyes"];
        [self customInitSubViews];
    }
    return self;
}

- (void)customInitSubViews
{
    [self __initImageView];
    [self __initBackBarButton];
    [self __initVoiceButton];
    [self __initActivityIndicator];
    [self transparentCutRoundArea];
}

- (void)showActionTips:(NSString *)actions
{
    self.actions = actions;
    DLog(@"-----actions:%@", self.actions);
    [self __initActionIndexView];
    [self __initFrontImage];
    [self __initActionImage];
    [self __initActionsText];
    [self showFrontImage];
}

- (void)changeTipStatus:(NSDictionary *)infoDict
{
    NSNumber *key = [[infoDict allKeys] firstObject];
    BOOL actionStatus = [[infoDict objectForKey:key] boolValue];
    if (actionStatus) {
        // 完成某个动作
        self.actionsCount++;
        // 显示下一个动作
        if (self.actionsCount < self.actions.length) {
            NSString *action = [self.actions substringWithRange:NSMakeRange(self.actionsCount, 1)];
            [self showActionImage:[self.imageArray objectAtIndex:[action integerValue]]];
            [self showActionIndex:self.actionsCount-1];
            [self playActionMusic:[self.musicArray objectAtIndex:[action integerValue]]];
        }
    }
    NSString *statusText = @"";
    switch ([key intValue]) {
        case 0:
            statusText = @"请正对手机屏幕\n将面部移入框内";
            break;
        case 1:
            statusText = @"慢慢右转头";
            break;
        case 2:
            statusText = @"慢慢左转头";
            break;
        case 3:
            statusText = @"张张嘴";
            break;
        case 4:
            statusText = @"眨眨眼";
            break;
        case -1:
            statusText = @"请正对手机屏幕\n将面部移入框内";
            break;
        default:
            break;
    }
    self.actionsText.text = statusText;
}

- (void)__initBackBarButton
{
    _backBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBarButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [_backBarButton setImage:[UIImage imageNamed:@"ico_back"] forState:UIControlStateNormal];
    [_backBarButton setImage:[UIImage imageNamed:@"ico_back"] forState:UIControlStateHighlighted];
    [self addSubview:_backBarButton];
    [_backBarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20*KWidthScale);
        make.top.equalTo(self).offset(IS_IPHONE_X ? 33+statusBarHeight : 27+statusBarHeight);
        make.width.equalTo(@(24*KWidthScale));
        make.height.equalTo(@(24*KWidthScale));
    }];
}

- (void)__initVoiceButton
{
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.shouldPlay) {
        [self.voiceButton setImage:[UIImage imageNamed:@"ico_voice_open"] forState:UIControlStateNormal];
    } else {
        [self.voiceButton  setImage:[UIImage imageNamed:@"ico_voice_close"] forState:UIControlStateNormal];
    }
    [self.voiceButton addTarget:self action:@selector(openVoiceButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voiceButton];
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-(20*KWidthScale));
        make.top.equalTo(self).offset(IS_IPHONE_X ? 33+statusBarHeight : 27+statusBarHeight);
        make.width.equalTo(@(24*KWidthScale));
        make.height.equalTo(@(24*KWidthScale));
    }];
}

- (void)__initActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicator setColor:[UIColor blueColor]];
    [self addSubview:_activityIndicator];
    [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@200);
        make.height.equalTo(@200);
    }];
}

- (void)__initImageView
{
    self.cameraImage = [[UIImageView alloc] init];
    [self addSubview:self.cameraImage];
    [self.cameraImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).mas_offset(IS_IPHONE_X ? 50+statusBarHeight : 4+statusBarHeight);
        make.width.equalTo(@(imageViewWidth));
        make.height.equalTo(@(imageViewHeight));
    }];
}

- (void)__initActionsText
{
    self.actionsText = [[UILabel alloc] init];
    self.actionsText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20*KWidthScale];
    self.actionsText.textColor = UIColorFromHex(0x000000);
    self.actionsText.numberOfLines = 0;
    [self addSubview:self.actionsText];
    [self.actionsText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.frontImage.mas_top).mas_offset(-4*KWidthScale);
    }];
}

- (void)__initActionIndexView
{
    // 正面不算入动作序列
    int indexNumber = (int)self.actions.length - 1;
    self.actionIndexView = [[UIView alloc] init];
    [self addSubview:self.actionIndexView];
    CGFloat viewY = IS_IPHONE_X ? (SCREEN_HEIGHT - 45*KWidthScale - 34) : (SCREEN_HEIGHT - 45*KWidthScale);
    self.actionIndexView.frame = CGRectMake(0, viewY, SCREEN_WIDTH, 20*KWidthScale);
    
    self.leftPadding = (SCREEN_WIDTH - 20 * (indexNumber - 1) * KWidthScale - 10 * indexNumber * KWidthScale) / 2;
    NSMutableArray *indexViews = [NSMutableArray array];
    for (int i=0; i<indexNumber; i++) {
        UILabel *actionIndexLabel = [[UILabel alloc] init];
        actionIndexLabel.backgroundColor = UIColorFromHex(0xdde3ef);
        actionIndexLabel.textColor = UIColorFromHex(0xffffff);
        actionIndexLabel.textAlignment = NSTextAlignmentCenter;
        actionIndexLabel.text = @"";
        actionIndexLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:14*KWidthScale];
        actionIndexLabel.layer.cornerRadius = 5*KWidthScale;
        actionIndexLabel.layer.masksToBounds = YES;
        actionIndexLabel.frame = CGRectMake(30*KWidthScale*i+self.leftPadding, 5*KWidthScale, 10*KWidthScale, 10*KWidthScale);
        if (i == 0) {
            actionIndexLabel.text = @"1";
            actionIndexLabel.backgroundColor = UIColorFromHex(0x2B63FF);
            actionIndexLabel.layer.cornerRadius = 10 * KWidthScale;
            actionIndexLabel.frame = CGRectMake(30*KWidthScale*i-5*KWidthScale+self.leftPadding, 0, 20*KWidthScale, 20*KWidthScale);
        }
        [self.actionIndexView addSubview:actionIndexLabel];
        [indexViews addObject:actionIndexLabel];
    }
    self.indexViewArray = [indexViews copy];
}

- (void)showActionIndex:(NSUInteger)index
{
    for (int i=0; i<index; i++) {
        UILabel *indexLabel = (UILabel *)self.indexViewArray[i];
        indexLabel.text = @"";
        indexLabel.backgroundColor = UIColorFromHex(0x2B63FF);
        indexLabel.layer.cornerRadius = 5 * KWidthScale;
        indexLabel.frame = CGRectMake(30*KWidthScale*i+self.leftPadding, 5*KWidthScale, 10*KWidthScale, 10*KWidthScale);
    }
    UILabel *currentIndexLabel = (UILabel *)self.indexViewArray[index];
    currentIndexLabel.backgroundColor = UIColorFromHex(0x2B63FF);
    currentIndexLabel.text = [NSString stringWithFormat:@"%d", (int)(index+1)];
    currentIndexLabel.layer.cornerRadius = 10 * KWidthScale;
    currentIndexLabel.frame = CGRectMake(30*KWidthScale*index-5*KWidthScale+self.leftPadding, 0, 20*KWidthScale, 20*KWidthScale);
}

- (void)__initFrontImage
{
    self.frontImage = [[UIImageView alloc] init];
    self.frontImage.image = [UIImage imageNamed:@"pic_front"];
    [self addSubview:self.frontImage];
    [self.frontImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionIndexView.mas_top).offset(-16*KWidthScale);
        make.centerX.equalTo(self);
        make.width.equalTo(@(140*KWidthScale));
        make.height.equalTo(@(140*KWidthScale));
    }];
}

- (void)__initActionImage
{
    self.actionImage = [[UIImageView alloc] init];
    [self addSubview:self.actionImage];
    [self.actionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionIndexView.mas_top).offset(-16*KWidthScale);
        make.centerX.equalTo(self);
        make.width.equalTo(@(140*KWidthScale));
        make.height.equalTo(@(140*KWidthScale));
    }];
}

- (void)showActionImage:(NSString *)imageName
{
    // 0——正面，1——右转，2——左转，3——张嘴，4——眨眼
    self.frontImage.hidden = YES;
    self.actionImage.hidden = NO;
    NSString *gifImagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"gif"];
    NSURL *gifImageUrl = [NSURL fileURLWithPath:gifImagePath];
    [self.actionImage yh_setImage:gifImageUrl];
}

- (void)playActionMusic:(NSString *)musicName
{
    // 0——正面，1——右转，2——左转，3——张嘴，4——眨眼
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:musicName withExtension:@"wav"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    if (self.player) {
        [self.player prepareToPlay];
    }
    if (self.shouldPlay) {
        [self.player play];
    } else {
        [self.player stop];
    }
}

- (void)showFrontImage
{
    self.frontImage.hidden = NO;
    self.actionImage.hidden = YES;
}

//圆形裁剪区域
-(void)transparentCutRoundArea{

    // 圆形透明区域
    UIBezierPath *alphaPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(imageViewWidth/2, imageViewHeight/2) radius:cameraViewRadius-1 startAngle:0 endAngle:2*M_PI clockwise:NO];
    [alphaPath appendPath:arcPath];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.path = alphaPath.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.zPosition = 1.0f;
    [self.cameraImage.layer addSublayer:layer];
    
    // 圆形裁剪框
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(imageViewWidth/2, imageViewHeight/2) radius:cameraViewRadius startAngle:0 endAngle:2*M_PI clockwise:NO];
    CAShapeLayer *cropLayer = [CAShapeLayer layer];
    cropLayer.path = cropPath.CGPath;
    cropLayer.strokeColor = [UIColor whiteColor].CGColor;
    cropLayer.fillColor = [UIColor clearColor].CGColor;
    cropLayer.zPosition = 2.0f;
    [self.cameraImage.layer addSublayer:cropLayer];
}

- (void)openVoiceButton
{
    self.shouldPlay = !self.shouldPlay;
    if (self.shouldPlay) {
        [self.voiceButton setImage:[UIImage imageNamed:@"ico_voice_open"] forState:UIControlStateNormal];
    } else {
        [self.voiceButton  setImage:[UIImage imageNamed:@"ico_voice_close"] forState:UIControlStateNormal];
    }
}

- (void)doBack
{
    if ([self.LDViewDelegate respondsToSelector:@selector(backBarButtonPressed)]) {
        [self.LDViewDelegate backBarButtonPressed];
    }
}

@end