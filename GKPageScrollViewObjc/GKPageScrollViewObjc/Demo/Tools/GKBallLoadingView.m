//
//  GKBallLoadingView.m
//  GKDYVideo
//
//  Created by gaokun on 2019/5/7.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKBallLoadingView.h"

#define kBallWidth      12.0f
#define kBallSpeed      0.7f
#define kBallZoomScale  0.25
#define kBallPauseTime  0.18

// 球的运动方向，以绿球向右、红球向左运动为正向
typedef NS_ENUM(NSUInteger, GKBallMoveDirection) {
    GKBallMoveDirectionPositive = 1,    // 正向运动
    GKBallMoveDirectionNegative = -1    // 逆向运动
};

@interface GKBallLoadingView()

// 球容器视图
@property (nonatomic, strong) UIView                *containerView;

// 绿球
@property (nonatomic, strong) UIView                *greenBall;

// 红球
@property (nonatomic, strong) UIView                *redBall;

// 黑球
@property (nonatomic, strong) UIView                *blackBall;

@property (nonatomic, assign) GKBallMoveDirection   moveDirection;

// 定时器
@property (nonatomic, strong) CADisplayLink         *displayLink;

@end

@implementation GKBallLoadingView

+ (instancetype)loadingViewInView:(UIView *)view {
    GKBallLoadingView *loadingView = [[GKBallLoadingView alloc] initWithFrame:view.bounds];
    [view addSubview:loadingView];
    return loadingView;
}

- (void)startLoadingWithProgress:(CGFloat)progress {
    [self updateBallPositionWithProgress:progress];
}

- (void)startLoading {
    [self startAnimation];
}

- (void)stopLoading {
    [self stopAnimation];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.containerView = [[UIView alloc] init];
    self.containerView.center = self.center;
    self.containerView.bounds = CGRectMake(0, 0, 2.1f * kBallWidth, 2.0f * kBallWidth);
    [self addSubview:self.containerView];
    
    // 绿球
    self.greenBall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBallWidth, kBallWidth)];
    self.greenBall.center = CGPointMake(kBallWidth * 0.5f, self.containerView.bounds.size.height * 0.5f);
    self.greenBall.layer.cornerRadius = kBallWidth * 0.5f;
    self.greenBall.layer.masksToBounds = YES;
    self.greenBall.backgroundColor = GKColorRGB(35, 246, 235);
    [self.containerView addSubview:self.greenBall];
    
    // 红球
    self.redBall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBallWidth, kBallWidth)];
    self.redBall.center = CGPointMake(self.containerView.bounds.size.width - kBallWidth * 0.5f, self.containerView.bounds.size.height * 0.5f);
    self.redBall.layer.cornerRadius = kBallWidth * 0.5f;
    self.redBall.layer.masksToBounds = YES;
    self.redBall.backgroundColor = GKColorRGB(255, 46, 86);
    [self.containerView addSubview:self.redBall];
    
    // 黑球
    // 第一次动画是正向，绿球在上，红球在下，阴影显示在绿球上
    self.blackBall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBallWidth, kBallWidth)];
    self.blackBall.backgroundColor = GKColorRGB(12, 11, 17);
    self.blackBall.layer.cornerRadius = kBallWidth * 0.5f;
    self.blackBall.layer.masksToBounds = YES;
    [self.greenBall addSubview:self.blackBall];
    
    // 方向
    self.moveDirection = GKBallMoveDirectionPositive;
    [self.containerView bringSubviewToFront:self.greenBall];
    [self updateBallPositionWithProgress:0];
}

- (void)startAnimation {
    [self pauseAnimation];
    
    // 创建并开启定时器
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateBallAnimations)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)pauseAnimation {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)stopAnimation {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }

    // 取消延时方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimation) object:nil];
    
    // 恢复初始化位置
    [self.greenBall addSubview:self.blackBall];
    [self.containerView bringSubviewToFront:self.greenBall];
    self.moveDirection = GKBallMoveDirectionPositive;
    [self updateBallPositionWithProgress:0];
}

- (void)resetAnimation {
    [self pauseAnimation];
    // 延时执行方法
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:kBallPauseTime];
}

- (void)updateBallPositionWithProgress:(CGFloat)progress {
    CGPoint center = self.greenBall.center;
    center.x = kBallWidth * 0.5 + 1.1 * kBallWidth * progress;
    self.greenBall.center = center;
    
    center = self.redBall.center;
    center.x = kBallWidth * 1.6 - 1.1 * kBallWidth * progress;
    self.redBall.center = center;
    
    // 缩放动画，绿球放大，红球缩小
    if (progress != 0 && progress != 1) {
        self.greenBall.transform = [self ballLargerTransformOfCenterX:center.x];
        self.redBall.transform   = [self ballSmallerTransformOfCenterX:center.x];
    }else {
        self.greenBall.transform = CGAffineTransformIdentity;
        self.redBall.transform   = CGAffineTransformIdentity;
    }
    
    // 更新黑球位置
    CGRect blackBallFrame = [self.redBall convertRect:self.redBall.bounds toCoordinateSpace:self.greenBall];
    self.blackBall.frame = blackBallFrame;
    self.blackBall.layer.cornerRadius = self.blackBall.bounds.size.width * 0.5f;
}

- (void)updateBallAnimations {
    if (self.moveDirection == GKBallMoveDirectionPositive) { // 正向
        CGPoint center = self.greenBall.center;
        center.x += kBallSpeed;
        self.greenBall.center = center;
        
        center = self.redBall.center;
        center.x -= kBallSpeed;
        self.redBall.center = center;
        
        // 缩放动画，绿球放大，红球缩小
        self.greenBall.transform = [self ballLargerTransformOfCenterX:center.x];
        self.redBall.transform   = [self ballSmallerTransformOfCenterX:center.x];
        
        // 更新黑球位置
        CGRect blackBallFrame = [self.redBall convertRect:self.redBall.bounds toCoordinateSpace:self.greenBall];
        self.blackBall.frame = blackBallFrame;
        self.blackBall.layer.cornerRadius = self.blackBall.bounds.size.width * 0.5f;
        
        // 更新方向 改变三个球的相对位置
        if (CGRectGetMaxX(self.greenBall.frame) >= self.containerView.bounds.size.width || CGRectGetMinX(self.redBall.frame) <= 0) {
            // 切换为反向
            self.moveDirection = GKBallMoveDirectionNegative;
            
            // 反向运动时，红球在上，绿球在下
            [self.containerView bringSubviewToFront:self.redBall];
            
            // 黑球放在红球上面
            [self.redBall addSubview:self.blackBall];
            
            // 重置动画
            [self resetAnimation];
        }
    }else if (self.moveDirection == GKBallMoveDirectionNegative) { // 反向
        // 更新绿球位置
        CGPoint center = self.greenBall.center;
        center.x -= kBallSpeed;
        self.greenBall.center = center;
        
        // 更新红球位置
        center = self.redBall.center;
        center.x += kBallSpeed;
        self.redBall.center = center;
        
        // 缩放动画 红球放大 绿球缩小
        self.redBall.transform = [self ballLargerTransformOfCenterX:center.x];
        self.greenBall.transform = [self ballSmallerTransformOfCenterX:center.x];
        
        // 更新黑球位置
        CGRect blackBallFrame = [self.greenBall convertRect:self.greenBall.bounds toCoordinateSpace:self.redBall];
        self.blackBall.frame = blackBallFrame;
        self.blackBall.layer.cornerRadius = self.blackBall.bounds.size.width * 0.5f;
        
        // 更新方向 改变三个球的相对位置
        if (CGRectGetMinX(self.greenBall.frame) <= 0 || CGRectGetMaxX(self.redBall.frame) >= self.containerView.bounds.size.width) {
            // 切换为正向
            self.moveDirection = GKBallMoveDirectionPositive;
            // 正向运动 绿球在上 红球在下
            [self.containerView bringSubviewToFront:self.greenBall];
            // 黑球放在绿球上面
            [self.greenBall addSubview:self.blackBall];
            // 重置动画
            [self resetAnimation];
        }
    }
}

// 放大动画
- (CGAffineTransform)ballLargerTransformOfCenterX:(CGFloat)centerX {
    CGFloat cosValue = [self cosValueOfCenterX:centerX];
    return CGAffineTransformMakeScale(1 + cosValue * kBallZoomScale, 1 + cosValue * kBallZoomScale);
}

// 缩小动画
- (CGAffineTransform)ballSmallerTransformOfCenterX:(CGFloat)centerX {
    CGFloat cosValue = [self cosValueOfCenterX:centerX];
    return CGAffineTransformMakeScale(1 - cosValue * kBallZoomScale, 1 - cosValue * kBallZoomScale);
}

// 根据余弦函数获取变化区间 变化范围是0~1~0
- (CGFloat)cosValueOfCenterX:(CGFloat)centerX {
    // 移动距离
    CGFloat apart = centerX - self.containerView.bounds.size.width * 0.5f;
    // 最大距离(球心距离Container中心距离)
    CGFloat maxAppart = (self.containerView.bounds.size.width - kBallWidth) * 0.5f;
    // 移动距离和最大距离的比例
    CGFloat angle = apart / maxAppart * M_PI_2;
    // 获取比例对应余弦曲线的Y值
    return cos(angle);
}

@end
