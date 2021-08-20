//
//  JXCategorySubTitleImageView.h
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleView.h"
#import "JXCategorySubTitleImageCell.h"
#import "JXCategorySubTitleImageCellModel.h"

@interface JXCategorySubTitleImageView : JXCategorySubTitleView

// 自定义imageView类
@property (nonatomic, strong) Class imageViewClass;
//imageInfo数组可以传入imageName字符串或者image的URL地址等，然后会通过loadImageBlock透传回来，把imageView对于图片的加载过程完全交给使用者决定。
@property (nonatomic, strong) NSArray <id>*imageInfoArray;
@property (nonatomic, strong) NSArray <id>*selectedImageInfoArray;
@property (nonatomic, copy) void(^loadImageBlock)(UIImageView *imageView, id info);
//图片尺寸。默认CGSizeMake(20, 20)
@property (nonatomic, assign) CGSize imageSize;
//titleLabel和ImageView的间距，默认5
@property (nonatomic, assign) CGFloat titleImageSpacing;
//图片是否缩放。默认为NO
@property (nonatomic, assign, getter=isImageZoomEnabled) BOOL imageZoomEnabled;
//图片缩放的最大scale。默认1.2，imageZoomEnabled为YES才生效
@property (nonatomic, assign) CGFloat imageZoomScale;

//默认@[JXCategorySubTitleImageType_None...]
@property (nonatomic, strong) NSArray <NSNumber *> *imageTypes;

// 计算指示器位置时是否忽略图片的宽度
@property (nonatomic, assign, getter=isIgnoreImageWidth) BOOL ignoreImageWidth;

@end
