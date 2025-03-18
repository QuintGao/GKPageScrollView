//
//  GKCustomSegmentedView.h
//  ObjcExample
//
//  Created by QuintGao on 2025/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKCustomSegmentedViewDelegate <NSObject>

- (void)didClickSelectAtIndex:(NSInteger)index;

@end

@interface GKCustomSegmentedView : UIView

@property (nonatomic, weak) id<GKCustomSegmentedViewDelegate> delegate;

- (void)scrollSelectWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
