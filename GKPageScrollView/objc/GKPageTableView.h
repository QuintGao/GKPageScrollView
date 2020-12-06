//
//  GKPageTableView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/26.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPageTableView;

@protocol GKPageTableViewGestureDelegate <NSObject>

@optional

- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@interface GKPageTableView : UITableView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<GKPageTableViewGestureDelegate> gestureDelegate;

@property (nonatomic, strong) NSArray *horizontalScrollViewList;

@end

NS_ASSUME_NONNULL_END
