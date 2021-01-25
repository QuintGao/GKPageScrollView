//
//  JXCategorySubTitleView.h
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategoryTitleView.h"
#import "JXCategorySubTitleCell.h"
#import "JXCategorySubTitleCellModel.h"

@interface JXCategorySubTitleView : JXCategoryTitleView

// 子标题列表
@property (nonatomic, strong) NSArray <NSString *> *subTitles;

// 子标题相对于title的位置，默认JXCategorySubTitlePositionStyle_Bottom
@property (nonatomic, assign) JXCategorySubTitlePositionStyle positionStyle;

// 子标题相当于title的对齐，默认JXCategorySubTitleAlignStyle_Center
// 当positionStyle为上下时，对齐方式左中右有效
// 当positionStyle为左右时，对齐方式上中下有效
@property (nonatomic, assign) JXCategorySubTitleAlignStyle alignStyle;

// 子标题相对于title的间距，默认0
@property (nonatomic, assign) CGFloat subTitleWithTitlePositionMargin;

// 子标题相当于title的对齐间距，默认0
@property (nonatomic, assign) CGFloat subTitleWithTitleAlignMargin;

// 子标题默认颜色 // 默认：[UIColor blackColor]
@property (nonatomic, strong) UIColor *subTitleColor;

// 子标题选中颜色 // 默认：[UIColor blackColor]
@property (nonatomic, strong) UIColor *subTitleSelectedColor;

// 子标题默认字体 // 默认：[UIFont systemFontOfSize:12]
@property (nonatomic, strong) UIFont *subTitleFont;

// 子标题选中字体 //文字被选中的字体。默认：与titleFont一样
@property (nonatomic, strong) UIFont *subTitleSelectedFont;

// 是否忽略subTitle宽度，默认NO，此属性只在positionStyle为左右时有效
@property (nonatomic, assign, getter=isIgnoreSubTitleWidth) BOOL ignoreSubTitleWidth;

@end
