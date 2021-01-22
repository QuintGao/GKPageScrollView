//
//  JXCategorySubTitleView.m
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleView.h"

@implementation JXCategorySubTitleView

- (void)initializeData {
    [super initializeData];

    _subTitleColor = [UIColor blackColor];
    _subTitleSelectedColor = [UIColor blackColor];
    _subTitleFont = [UIFont systemFontOfSize:12];
    _positionStyle = JXCategorySubTitlePositionStyle_Bottom;
    _alignStyle = JXCategorySubTitleAlignStyle_Center;
    _subTitleWithTitlePositionMargin = 0;
    _subTitleWithTitleAlignMargin = 0;
}

- (UIFont *)subTitleSelectedFont {
    if (_subTitleSelectedFont) {
        return _subTitleSelectedFont;
    }
    return _subTitleFont;
}

#pragma mark - Override
- (Class)preferredCellClass {
    return [JXCategorySubTitleCell class];
}

- (void)refreshDataSource {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.titles.count];
    for (int i = 0; i < self.titles.count; i++) {
        JXCategorySubTitleCellModel *cellModel = [[JXCategorySubTitleCellModel alloc] init];
        [tempArray addObject:cellModel];
    }
    self.dataSource = [NSArray arrayWithArray:tempArray];
}

- (void)refreshSelectedCellModel:(JXCategoryBaseCellModel *)selectedCellModel unselectedCellModel:(JXCategoryBaseCellModel *)unselectedCellModel {
    [super refreshSelectedCellModel:selectedCellModel unselectedCellModel:unselectedCellModel];

    JXCategorySubTitleCellModel *myUnselectedCellModel = (JXCategorySubTitleCellModel *)unselectedCellModel;
    JXCategorySubTitleCellModel *myselectedCellModel = (JXCategorySubTitleCellModel *)selectedCellModel;
    
    myselectedCellModel.subTitleCurrentColor = myselectedCellModel.subTitleSelectedColor;
    myUnselectedCellModel.subTitleCurrentColor = myUnselectedCellModel.subTitleNormalColor;
}

- (void)refreshLeftCellModel:(JXCategoryBaseCellModel *)leftCellModel rightCellModel:(JXCategoryBaseCellModel *)rightCellModel ratio:(CGFloat)ratio {
    [super refreshLeftCellModel:leftCellModel rightCellModel:rightCellModel ratio:ratio];
}

- (CGFloat)preferredCellWidthAtIndex:(NSInteger)index {
    if (self.cellWidth == JXCategoryViewAutomaticDimension) {
        if (self.titleDataSource && [self.titleDataSource respondsToSelector:@selector(categoryTitleView:widthForTitle:)]) {
            return [self.titleDataSource categoryTitleView:self widthForTitle:self.titles[index]];
        } else {
            CGFloat titleW = ceilf([self.titles[index] boundingRectWithSize:CGSizeMake(MAXFLOAT, self.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.titleFont} context:nil].size.width);
            CGFloat subTitleW = ceilf([self.subTitles[index] boundingRectWithSize:CGSizeMake(MAXFLOAT, self.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.subTitleFont} context:nil].size.width);
            if (self.positionStyle == JXCategorySubTitlePositionStyle_Top || self.positionStyle == JXCategoryComponentPosition_Bottom) {
                return MAX(titleW, subTitleW);
            }else {
                return titleW + subTitleW;
            }
        }
    } else {
        return self.cellWidth;
    }
}

- (void)refreshCellModel:(JXCategoryBaseCellModel *)cellModel index:(NSInteger)index {
    [super refreshCellModel:cellModel index:index];

    JXCategorySubTitleCellModel *model = (JXCategorySubTitleCellModel *)cellModel;
    model.subTitle = self.subTitles[index];
    model.subTitleFont = self.subTitleFont;
    model.subTitleSelectedFont = self.subTitleSelectedFont;
    model.subTitleNormalColor = self.subTitleColor;
    model.subTitleSelectedColor = self.subTitleSelectedColor;
    model.positionStyle = self.positionStyle;
    model.alignStyle = self.alignStyle;
    model.subTitleWithTitlePositionMargin = self.subTitleWithTitlePositionMargin;
    model.subTitleWithTitleAlignMargin = self.subTitleWithTitleAlignMargin;
    if (index == self.selectedIndex) {
        model.subTitleCurrentColor = model.subTitleSelectedColor;
    }else {
        model.subTitleCurrentColor = model.subTitleNormalColor;
    }
}

- (CGRect)getTargetCellFrame:(NSInteger)targetIndex {
    CGRect frame = [super getTargetCellFrame:targetIndex];
    if (self.isIgnoreSubTitleWidth) {
        if (targetIndex >= 0 && targetIndex < self.subTitles.count) {
            NSString *subTitle = self.subTitles[targetIndex];
            CGFloat subTitleWidth = [subTitle sizeWithAttributes:@{NSFontAttributeName: self.subTitleFont}].width;
            frame.size.width -= subTitleWidth;
            if (self.positionStyle == JXCategorySubTitlePositionStyle_Left) {
                frame.origin.x += subTitleWidth;
            }
        }
    }
    return frame;
}

- (CGRect)getTargetSelectedCellFrame:(NSInteger)targetIndex selectedType:(JXCategoryCellSelectedType)selectedType {
    CGRect frame = [super getTargetSelectedCellFrame:targetIndex selectedType:selectedType];
    if (self.isIgnoreSubTitleWidth) {
        if (targetIndex >= 0 && targetIndex < self.subTitles.count) {
            NSString *subTitle = self.subTitles[targetIndex];
            CGFloat subTitleWidth = [subTitle sizeWithAttributes:@{NSFontAttributeName: self.subTitleFont}].width;
            frame.size.width -= subTitleWidth;
            if (self.positionStyle == JXCategorySubTitlePositionStyle_Left) {
                frame.origin.x += subTitleWidth;
            }
        }
    }
    return frame;
}

@end
