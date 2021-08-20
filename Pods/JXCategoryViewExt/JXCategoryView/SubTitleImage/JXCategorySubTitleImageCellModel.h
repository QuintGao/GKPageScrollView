//
//  JXCategorySubTitleImageCellModel.h
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleCellModel.h"

// image相对于title的位置，只支持左右
typedef NS_ENUM(NSUInteger, JXCategorySubTitleImageType) {
    JXCategorySubTitleImageType_None,   // 无图片
    JXCategorySubTitleImageType_Left,   // 在标题左边
    JXCategorySubTitleImageType_Right   // 在标题右边
};

@interface JXCategorySubTitleImageCellModel : JXCategorySubTitleCellModel

@property (nonatomic, assign) JXCategorySubTitleImageType imageType;

@property (nonatomic, strong) Class imageViewClass;

@property (nonatomic, strong) id imageInfo;
@property (nonatomic, strong) id selectedImageInfo;
@property (nonatomic, copy) void(^loadImageBlock)(UIImageView *imageView, id info);
@property (nonatomic, assign) CGSize imageSize; // 默认CGSizeMake(20, 20)
@property (nonatomic, assign) CGFloat titleImageSpacing;    // titleLabel和imageView的间距，默认5
@property (nonatomic, assign, getter=isImageZoomEnabled) BOOL imageZoomEnabled;
@property (nonatomic, assign) CGFloat imageZoomScale;

@end
