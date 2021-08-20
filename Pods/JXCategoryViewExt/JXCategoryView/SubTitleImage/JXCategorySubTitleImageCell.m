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
@property (nonatomic, strong) UIStackView *stackView;
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

    [self.titleLabel removeFromSuperview];
    
    [self initialImageViewWithClass:[UIImageView class]];
    
    _stackView = [[UIStackView alloc] init];
    self.stackView.alignment = UIStackViewAlignmentCenter;
    [self.contentView addSubview:self.stackView];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.stackView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
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

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];
    
    JXCategorySubTitleImageCellModel *myCellModel = (JXCategorySubTitleImageCellModel *)cellModel;
    if (myCellModel.imageViewClass) {
        [self initialImageViewWithClass:myCellModel.imageViewClass];
    }
    
    self.imageView.hidden = NO;
    [self.stackView removeArrangedSubview:self.titleLabel];
    [self.stackView removeArrangedSubview:self.imageView];
    CGSize imageSize = myCellModel.imageSize;
    self.imageViewWidthConstraint.constant = imageSize.width;
    self.imageViewHeightConstraint.constant = imageSize.height;
    self.stackView.spacing = myCellModel.titleImageSpacing;
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    
    switch (myCellModel.imageType) {
        case JXCategorySubTitleImageType_Left:
            [self.stackView addArrangedSubview:self.imageView];
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        case JXCategorySubTitleImageType_Right:
            [self.stackView addArrangedSubview:self.titleLabel];
            [self.stackView addArrangedSubview:self.imageView];
            break;
        default:
            self.imageView.hidden = YES;
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
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
