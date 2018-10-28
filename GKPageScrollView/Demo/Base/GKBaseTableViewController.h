//
//  GKBaseTableViewController.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDemoBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKBaseTableViewController : GKDemoBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView   *tableView;

@end

NS_ASSUME_NONNULL_END
