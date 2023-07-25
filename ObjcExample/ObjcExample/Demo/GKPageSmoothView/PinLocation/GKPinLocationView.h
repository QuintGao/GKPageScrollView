//
//  GKPinLocationView.h
//  ObjcExample
//
//  Created by QuintGao on 2021/2/5.
//

#import <UIKit/UIKit.h>
#import <GKPageSmoothView/GKPageSmoothView.h>

typedef NS_ENUM(NSUInteger, GKPinLocationViewType) {
    GKPinLocationViewType_TableView,
    GKPinLocationViewType_CollectionView
};

NS_ASSUME_NONNULL_BEGIN

@protocol GKPinLocationViewDelegate <NSObject>

- (void)locationViewDidEndAnimation:(UIScrollView *)scrollView;

@end

@interface GKPinLocationView : UIView<GKPageSmoothListViewDelegate>

@property (nonatomic, weak) id<GKPinLocationViewDelegate> delegate;

@property (nonatomic, strong) NSArray *data;

@end

NS_ASSUME_NONNULL_END
