//
//  JXCategorySubTitleCellModel.h
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategoryTitleCellModel.h"

// subTitle相对于title的位置
typedef NS_ENUM(NSUInteger, JXCategorySubTitlePositionStyle) {
    JXCategorySubTitlePositionStyle_Top,
    JXCategorySubTitlePositionStyle_Left,
    JXCategorySubTitlePositionStyle_Bottom,
    JXCategorySubTitlePositionStyle_Right
};

// subTitle相当于title的对齐方式
typedef NS_ENUM(NSUInteger, JXCategorySubTitleAlignStyle) {
    JXCategorySubTitleAlignStyle_Center,
    JXCategorySubTitleAlignStyle_Left,
    JXCategorySubTitleAlignStyle_Right,
    JXCategorySubTitleAlignStyle_Top,
    JXCategorySubTitleAlignStyle_Bottom
};

@interface JXCategorySubTitleCellModel : JXCategoryTitleCellModel

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, assign) JXCategorySubTitlePositionStyle positionStyle;

@property (nonatomic, assign) JXCategorySubTitleAlignStyle alignStyle;

@property (nonatomic, assign) CGFloat subTitleWithTitlePositionMargin;
@property (nonatomic, assign) CGFloat subTitleWithTitleAlignMargin;

@property (nonatomic, assign, readonly) CGSize subTitleSize;

@property (nonatomic, strong) UIColor *subTitleNormalColor;
@property (nonatomic, strong) UIColor *subTitleCurrentColor;
@property (nonatomic, strong) UIColor *subTitleSelectedColor;

@property (nonatomic, strong) UIFont *subTitleFont;
@property (nonatomic, strong) UIFont *subTitleSelectedFont;

@end
