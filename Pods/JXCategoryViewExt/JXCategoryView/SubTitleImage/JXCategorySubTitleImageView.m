//
//  JXCategorySubTitleImageView.m
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleImageView.h"
#import "JXCategoryFactory.h"

@implementation JXCategorySubTitleImageView

- (void)dealloc {
    self.loadImageBlock = nil;
}

- (void)initializeData {
    [super initializeData];

    _imageSize = CGSizeMake(20, 20);
    _titleImageSpacing = 5;
    _imageZoomEnabled = NO;
    _imageZoomScale = 1.2;
}

#pragma mark - Override
- (Class)preferredCellClass {
    return [JXCategorySubTitleImageCell class];
}

- (void)refreshDataSource {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.titles.count];
    for (int i = 0; i < self.titles.count; i++) {
        JXCategorySubTitleImageCellModel *cellModel = [[JXCategorySubTitleImageCellModel alloc] init];
        [tempArray addObject:cellModel];
    }
    self.dataSource = [NSArray arrayWithArray:tempArray];
    
    if (!self.imageTypes || self.imageTypes.count == 0) {
        NSMutableArray *types = [NSMutableArray arrayWithCapacity:self.titles.count];
        for (int i = 0; i < self.titles.count; i++) {
            [types addObject:@(JXCategorySubTitleImageType_None)];
        }
        self.imageTypes = [NSArray arrayWithArray:types];
    }
}

- (void)refreshCellModel:(JXCategoryBaseCellModel *)cellModel index:(NSInteger)index {
    [super refreshCellModel:cellModel index:index];
    
    JXCategorySubTitleImageCellModel *myCellModel = (JXCategorySubTitleImageCellModel *)cellModel;
    myCellModel.loadImageBlock = self.loadImageBlock;
    myCellModel.imageType = [self.imageTypes[index] integerValue];
    myCellModel.imageSize = self.imageSize;
    myCellModel.titleImageSpacing = self.titleImageSpacing;
    if (self.imageInfoArray && self.imageInfoArray.count != 0) {
        myCellModel.imageInfo = self.imageInfoArray[index];
    }
    if (self.selectedImageInfoArray && self.selectedImageInfoArray.count != 0) {
        myCellModel.selectedImageInfo = self.selectedImageInfoArray[index];
    }
    myCellModel.imageZoomEnabled = self.imageZoomEnabled;
    myCellModel.imageZoomScale = ((index == self.selectedIndex) ? self.imageZoomScale : 1.0);
    myCellModel.subTitleInCenterX = self.subTitleInCenterX;
}

- (void)refreshSelectedCellModel:(JXCategoryBaseCellModel *)selectedCellModel unselectedCellModel:(JXCategoryBaseCellModel *)unselectedCellModel {
    [super refreshSelectedCellModel:selectedCellModel unselectedCellModel:unselectedCellModel];

    JXCategorySubTitleImageCellModel *myUnselectedCellModel = (JXCategorySubTitleImageCellModel *)unselectedCellModel;
    myUnselectedCellModel.imageZoomScale = 1.0;
    
    JXCategorySubTitleImageCellModel *myselectedCellModel = (JXCategorySubTitleImageCellModel *)selectedCellModel;
    myselectedCellModel.imageZoomScale = self.imageZoomScale;
}

- (void)refreshLeftCellModel:(JXCategoryBaseCellModel *)leftCellModel rightCellModel:(JXCategoryBaseCellModel *)rightCellModel ratio:(CGFloat)ratio {
    [super refreshLeftCellModel:leftCellModel rightCellModel:rightCellModel ratio:ratio];
    
    JXCategorySubTitleImageCellModel *leftModel = (JXCategorySubTitleImageCellModel *)leftCellModel;
    JXCategorySubTitleImageCellModel *rightModel = (JXCategorySubTitleImageCellModel *)rightCellModel;
    
    if (self.isImageZoomEnabled) {
        leftModel.imageZoomScale = [JXCategoryFactory interpolationFrom:self.imageZoomScale to:1.0 percent:ratio];
        rightModel.imageZoomScale = [JXCategoryFactory interpolationFrom:1.0 to:self.imageZoomScale percent:ratio];
    }
}

- (CGFloat)preferredCellWidthAtIndex:(NSInteger)index {
    if (self.cellWidth == JXCategoryViewAutomaticDimension) {
        CGFloat titleWidth = [super preferredCellWidthAtIndex:index];
        JXCategorySubTitlePositionStyle style = self.positionStyle;
        JXCategorySubTitleImageType type = [self.imageTypes[index] integerValue];
        CGFloat cellWidth = 0;
        if ((style == JXCategorySubTitlePositionStyle_Top || style == JXCategorySubTitlePositionStyle_Bottom) && type != JXCategorySubTitleImageType_None) {
            cellWidth = titleWidth + self.titleImageSpacing + self.imageSize.width;
        }else {
            cellWidth = titleWidth;
        }
        return cellWidth;
    } else {
        return self.cellWidth;
    }
}

- (CGRect)getTargetCellFrame:(NSInteger)targetIndex {
    CGRect frame = [super getTargetCellFrame:targetIndex];
    if (self.ignoreImageWidth && (self.positionStyle == JXCategorySubTitlePositionStyle_Top || self.positionStyle == JXCategorySubTitlePositionStyle_Bottom)) {
        if (targetIndex >= 0 && targetIndex < self.imageTypes.count) {
            JXCategorySubTitleImageType type = [self.imageTypes[targetIndex] integerValue];
            CGFloat imageWidth = 0;
            if (type != JXCategorySubTitleImageType_None) {
                imageWidth = self.titleImageSpacing + self.imageSize.width;
            }
            frame.size.width -= imageWidth;
            if (type == JXCategorySubTitleImageType_Left) {
                frame.origin.x += imageWidth;
            }
        }
    }
    return frame;
}

- (CGRect)getTargetSelectedCellFrame:(NSInteger)targetIndex selectedType:(JXCategoryCellSelectedType)selectedType {
    CGRect frame = [super getTargetSelectedCellFrame:targetIndex selectedType:selectedType];
    if (self.ignoreImageWidth && (self.positionStyle == JXCategorySubTitlePositionStyle_Top || self.positionStyle == JXCategorySubTitlePositionStyle_Bottom)) {
        if (targetIndex >= 0 && targetIndex < self.imageTypes.count) {
            JXCategorySubTitleImageType type = [self.imageTypes[targetIndex] integerValue];
            CGFloat imageWidth = 0;
            if (type != JXCategorySubTitleImageType_None) {
                imageWidth = self.titleImageSpacing + self.imageSize.width;
            }
            frame.size.width -= imageWidth;
            if (type == JXCategorySubTitleImageType_Left) {
                frame.origin.x += imageWidth;
            }
        }
    }
    return frame;
}

@end
