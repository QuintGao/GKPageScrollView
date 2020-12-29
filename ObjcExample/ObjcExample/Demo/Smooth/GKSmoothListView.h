//
//  GKSmoothListView.h
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/8.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageSmoothView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKSmoothListType) {
    GKSmoothListType_TableView,
    GKSmoothListType_CollectionView,
    GKSmoothListType_ScrollView,
    GKSmoothListType_WebView
};

@interface GKSmoothListView : UIView<GKPageSmoothListViewDelegate>

- (instancetype)initWithListType:(GKSmoothListType)listType;

- (void)requestData;

@end

NS_ASSUME_NONNULL_END
