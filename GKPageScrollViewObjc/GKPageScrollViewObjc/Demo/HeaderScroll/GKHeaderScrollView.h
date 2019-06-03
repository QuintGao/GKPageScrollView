//
//  GKHeaderScrollView.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/5/31.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKHeaderScrollViewDelegate <NSObject>

- (void)headerScrollViewWillBeginScroll;
- (void)headerScrollViewDidEndScroll;

@end

@interface GKHeaderScrollView : UIView

@property (nonatomic, weak) id<GKHeaderScrollViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
