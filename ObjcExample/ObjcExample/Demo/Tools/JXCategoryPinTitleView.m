//
//  JXCategoryPinTitleView.m
//  ObjcExample
//
//  Created by gaokun on 2021/2/5.
//

#import "JXCategoryPinTitleView.h"

@implementation JXCategoryPinTitleView

- (Class)preferredCellClass {
    return [JXCategoryPinTitleCell class];
}

- (void)refreshDataSource {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.titles.count];
    for (int i = 0; i < self.titles.count; i++) {
        JXCategoryPinTitleCellModel *cellModel = [[JXCategoryPinTitleCellModel alloc] init];
        [tempArray addObject:cellModel];
    }
    self.dataSource = [NSArray arrayWithArray:tempArray];
}

- (void)refreshCellModel:(JXCategoryBaseCellModel *)cellModel index:(NSInteger)index {
    [super refreshCellModel:cellModel index:index];
    
    JXCategoryPinTitleCellModel *myCellModel = (JXCategoryPinTitleCellModel *)cellModel;
    myCellModel.pinImage = self.pinImage;
    myCellModel.imageSize = self.pinImageSize;
}

@end
