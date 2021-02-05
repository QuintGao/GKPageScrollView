//
//  JXCategoryPinTitleView.h
//  ObjcExample
//
//  Created by gaokun on 2021/2/5.
//

#import "JXCategoryTitleView.h"
#import "JXCategoryPinTitleCell.h"
#import "JXCategoryPinTitleCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXCategoryPinTitleView : JXCategoryTitleView

@property (nonatomic, strong) UIImage *pinImage;
@property (nonatomic, assign) CGSize pinImageSize;

@end

NS_ASSUME_NONNULL_END
