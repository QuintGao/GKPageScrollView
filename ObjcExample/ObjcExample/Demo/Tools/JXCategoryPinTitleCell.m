//
//  JXCategoryPinTitleCell.m
//  ObjcExample
//
//  Created by gaokun on 2021/2/5.
//

#import "JXCategoryPinTitleCell.h"
#import "JXCategoryPinTitleCellModel.h"

@implementation JXCategoryPinTitleCell

- (void)initializeViews {
    [super initializeViews];
    
    self.pinImgView = [[UIImageView alloc] init];
    self.pinImgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.pinImgView];
    [self.pinImgView.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor].active = YES;
    [self.pinImgView.rightAnchor constraintEqualToAnchor:self.titleLabel.leftAnchor constant:-2].active = YES;
}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];
    
    JXCategoryPinTitleCellModel *myCellModel = (JXCategoryPinTitleCellModel *)cellModel;
    self.pinImgView.image = myCellModel.pinImage;
    self.pinImgView.hidden = !cellModel.selected;
    
    if (!CGSizeEqualToSize(myCellModel.imageSize, CGSizeZero)) {
        [self.pinImgView.widthAnchor constraintEqualToConstant:myCellModel.imageSize.width].active = YES;
        [self.pinImgView.heightAnchor constraintEqualToConstant:myCellModel.imageSize.height].active = YES;
    }
}

@end
