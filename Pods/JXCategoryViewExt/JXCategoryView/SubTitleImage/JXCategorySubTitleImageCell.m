//
//  JXCategorySubTitleImageCell.m
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleImageCell.h"
#import "JXCategorySubTitleImageCellModel.h"

@interface JXCategorySubTitleImageCell()
@property (nonatomic, strong) id currentImageInfo;
@property (nonatomic, strong) NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageViewHeightConstraint;
@end

@implementation JXCategorySubTitleImageCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.currentImageInfo = nil;
}

- (void)initializeViews {
    [super initializeViews];
    
    [self initialImageViewWithClass:[UIImageView class]];
    [self.contentView addSubview:self.imageView];
}

- (void)initialImageViewWithClass:(Class)cls {
    _imageView = [[cls alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewWidthConstraint = [self.imageView.widthAnchor constraintEqualToConstant:0];
    self.imageViewWidthConstraint.active = YES;
    self.imageViewHeightConstraint = [self.imageView.heightAnchor constraintEqualToConstant:0];
    self.imageViewHeightConstraint.active = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    JXCategorySubTitleImageCellModel *myCellModel = (JXCategorySubTitleImageCellModel *)self.cellModel;
    CGSize imageSize = myCellModel.imageSize;
    self.imageViewWidthConstraint.constant = imageSize.width;
    self.imageViewHeightConstraint.constant = imageSize.height;
    
    if (myCellModel.subTitleInCenterX && (myCellModel.positionStyle == JXCategorySubTitlePositionStyle_Top || myCellModel.positionStyle == JXCategorySubTitlePositionStyle_Bottom)) {
        [NSLayoutConstraint deactivateConstraints:@[self.subTitleLabelCenterX]];
        [self.subTitleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    }
    
    self.imageView.hidden = NO;
    self.titleLabelCenterX.constant = 0;
    
    switch (myCellModel.imageType) {
        case JXCategorySubTitleImageType_Left:
            [self.imageView.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor].active = YES;
            [self.imageView.rightAnchor constraintEqualToAnchor:self.titleLabel.leftAnchor constant:-myCellModel.titleImageSpacing].active = YES;
            self.titleLabelCenterX.constant = 2 * myCellModel.titleImageSpacing;
            break;
        case JXCategorySubTitleImageType_Right:
            [self.imageView.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor].active = YES;
            [self.imageView.leftAnchor constraintEqualToAnchor:self.titleLabel.rightAnchor constant:myCellModel.titleImageSpacing].active = YES;
            self.titleLabelCenterX.constant = -2 * myCellModel.titleImageSpacing;
            break;
        default:
            self.imageView.hidden = YES;
            break;
    }
}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];
    
    JXCategorySubTitleImageCellModel *myCellModel = (JXCategorySubTitleImageCellModel *)cellModel;
    if (myCellModel.imageViewClass) {
        [self initialImageViewWithClass:myCellModel.imageViewClass];
    }
    
    //因为`- (void)reloadData:(JXCategoryBaseCellModel *)cellModel`方法会回调多次，尤其是左右滚动的时候会调用无数次，如果每次都触发图片加载，会非常消耗性能。所以只会在图片发生了变化的时候，才进行图片加载。
    if (myCellModel.loadImageBlock != nil) {
        id currentImageInfo = myCellModel.imageInfo;
        if (myCellModel.isSelected) {
            currentImageInfo = myCellModel.selectedImageInfo;
        }
        if (currentImageInfo && [currentImageInfo isKindOfClass:[NSString class]] && ![currentImageInfo isEqualToString:self.currentImageInfo]) {
            self.currentImageInfo = currentImageInfo;
            myCellModel.loadImageBlock(self.imageView, currentImageInfo);
        }else if (currentImageInfo && currentImageInfo != self.currentImageInfo) {
            self.currentImageInfo = currentImageInfo;
            myCellModel.loadImageBlock(self.imageView, currentImageInfo);
        }
    }
    
    if (myCellModel.isImageZoomEnabled) {
        self.imageView.transform = CGAffineTransformMakeScale(myCellModel.imageZoomScale, myCellModel.imageZoomScale);
    }else {
        self.imageView.transform = CGAffineTransformIdentity;
    }
}

@end
