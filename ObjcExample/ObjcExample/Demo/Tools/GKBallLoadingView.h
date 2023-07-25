//
//  GKBallLoadingView.h
//  GKDYVideo
//
//  Created by QuintGao on 2019/5/7.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKBallLoadingView : UIView

+ (instancetype)loadingViewInView:(UIView *)view;

- (void)startLoadingWithProgress:(CGFloat)progress;

- (void)startLoading;
- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
