//
//  GKNestListView.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/9/30.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKNestListView : UIView

@property (nonatomic, strong) UITableView *tableView;

// 滑动回调
@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@end

NS_ASSUME_NONNULL_END
