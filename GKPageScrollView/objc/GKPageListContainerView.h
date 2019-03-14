//
//  GKPageListContainerView.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/3/13.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPageTableView, GKPageListContainerView;

@protocol GKPageListContainerViewDelegate <NSObject>

- (NSInteger)numberOfRowsInListContainerView:(GKPageListContainerView *)listContainerView;

- (UIView *)listContainerView:(GKPageListContainerView *)listContainerView listViewInRow:(NSInteger)row;

@end

@interface GKPageListContainerView : UIView

@property (nonatomic, strong, readonly) UICollectionView  *collectionView;

@property (nonatomic, weak) id<GKPageListContainerViewDelegate> delegate;

@property (nonatomic, weak) GKPageTableView *mainTableView;

- (instancetype)initWithDelegate:(id<GKPageListContainerViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
