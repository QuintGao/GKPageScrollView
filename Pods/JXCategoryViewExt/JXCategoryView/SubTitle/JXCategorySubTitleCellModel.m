//
//  JXCategorySubTitleCellModel.m
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleCellModel.h"

@implementation JXCategorySubTitleCellModel

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    
    [self updateNumberSizeWidthIfNeeded];
}

- (void)setSubTitleFont:(UIFont *)subTitleFont {
    _subTitleFont = subTitleFont;

    [self updateNumberSizeWidthIfNeeded];
}

- (void)updateNumberSizeWidthIfNeeded {
    if (self.subTitleFont) {
//        _subTitleSize = [self.subTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.subTitleFont} context:nil].size;
        _subTitleSize = [self.subTitle sizeWithAttributes:@{NSFontAttributeName: self.subTitleFont}];
    }
}

@end
