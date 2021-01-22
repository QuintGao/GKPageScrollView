//
//  JXCategorySubTitleCell.m
//  ObjcExample
//
//  Created by gaokun on 2021/1/21.
//

#import "JXCategorySubTitleCell.h"
#import "JXCategorySubTitleCellModel.h"

@interface JXCategorySubTitleCell()

@property (nonatomic, strong) NSLayoutConstraint *subTitleLabelCenterX;
@property (nonatomic, strong) NSLayoutConstraint *subTitleLabelCenterY;

@end

@implementation JXCategorySubTitleCell

- (void)initializeViews {
    [super initializeViews];

    _subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.clipsToBounds = YES;
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.subTitleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    JXCategorySubTitleCellModel *myCellModel = (JXCategorySubTitleCellModel *)self.cellModel;
    CGFloat positionMargin = myCellModel.subTitleWithTitlePositionMargin;
    [NSLayoutConstraint deactivateConstraints:self.subTitleLabel.constraints];
    switch (myCellModel.positionStyle) {
        case JXCategorySubTitlePositionStyle_Top: {
            [self.subTitleLabel.bottomAnchor constraintEqualToAnchor:self.titleLabel.topAnchor constant:positionMargin].active = YES;
            [self subTitleLeftRightConstraint:myCellModel];
            break;
        }
        case JXCategorySubTitlePositionStyle_Left: {
            self.titleLabelCenterX.active = NO;
            [self.titleLabel.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:0].active = YES;
            
            [self.subTitleLabel.rightAnchor constraintEqualToAnchor:self.titleLabel.leftAnchor constant:positionMargin].active = YES;
            [self subTitleTopBottomConstraint:myCellModel];
            break;
        }
        case JXCategorySubTitlePositionStyle_Bottom: {
            [self.subTitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:positionMargin].active = YES;
            [self subTitleLeftRightConstraint:myCellModel];
            break;
        }
        case JXCategorySubTitlePositionStyle_Right: {
            self.titleLabelCenterX.active = NO;
            [self.titleLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:0].active = YES;
            
            [self.subTitleLabel.leftAnchor constraintEqualToAnchor:self.titleLabel.rightAnchor constant:positionMargin].active = YES;
            [self subTitleTopBottomConstraint:myCellModel];
            break;
        }
    }
    [self.subTitleLabel.widthAnchor constraintEqualToConstant:ceilf(myCellModel.subTitleSize.width)].active = YES;
    [self.subTitleLabel.heightAnchor constraintEqualToConstant:ceilf(myCellModel.subTitleSize.height)].active = YES;
}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];

    JXCategorySubTitleCellModel *myCellModel = (JXCategorySubTitleCellModel *)cellModel;
    if (myCellModel.isSelected) {
        self.subTitleLabel.font = myCellModel.subTitleSelectedFont;
    }else {
        self.subTitleLabel.font = myCellModel.subTitleFont;
    }

    NSString *titleString = myCellModel.subTitle ? myCellModel.subTitle : @"";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleString];
    self.subTitleLabel.attributedText = attributedString;
    self.subTitleLabel.textColor = myCellModel.subTitleCurrentColor;
}

- (void)subTitleLeftRightConstraint:(JXCategorySubTitleCellModel *)cellModel {
    CGFloat alignMargin = cellModel.subTitleWithTitleAlignMargin;
    switch (cellModel.alignStyle) {
        case JXCategorySubTitleAlignStyle_Left: {
            [self.subTitleLabel.leftAnchor constraintEqualToAnchor:self.titleLabel.leftAnchor constant:alignMargin].active = YES;
            break;
        }
        case JXCategorySubTitleAlignStyle_Right: {
            [self.subTitleLabel.rightAnchor constraintEqualToAnchor:self.titleLabel.rightAnchor constant:alignMargin].active = YES;
            break;
        }
        default:
            [self.subTitleLabel.centerXAnchor constraintEqualToAnchor:self.titleLabel.centerXAnchor constant:alignMargin].active = YES;
            break;
    }
}

- (void)subTitleTopBottomConstraint:(JXCategorySubTitleCellModel *)cellModel {
    CGFloat alignMargin = cellModel.subTitleWithTitleAlignMargin;
    switch (cellModel.alignStyle) {
        case JXCategorySubTitleAlignStyle_Top: {
            [self.subTitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.topAnchor constant:alignMargin].active = YES;
            break;
        }
        case JXCategorySubTitleAlignStyle_Bottom: {
            [self.subTitleLabel.bottomAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:alignMargin].active = YES;
            break;
        }
        default:
            [self.subTitleLabel.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor constant:alignMargin].active = YES;
            break;
    }
}

@end
