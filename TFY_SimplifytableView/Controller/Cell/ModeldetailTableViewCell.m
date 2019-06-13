//
//  ModeldetailTableViewCell.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ModeldetailTableViewCell.h"

@interface ModeldetailTableViewCell ()

@property(nonatomic , strong)UIImageView *img_imageView;

@property(nonatomic , strong)UILabel *name_label;
@end


@implementation ModeldetailTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.img_imageView];
        
        self.img_imageView.tfy_LeftSpace(0).tfy_TopSpace(0).tfy_RightSpace(0).tfy_HeightAuto();
        
        [self.contentView addSubview:self.name_label];
        
        self.name_label.tfy_LeftSpace(0).tfy_TopSpaceToView(0, self.img_imageView).tfy_RightSpace(0).tfy_HeightAuto();
        
    }
    return self;
}

-(void)setModels:(Model_detail *)models{
    _models = models;
    
    self.img_imageView.image = [[UIImage imageNamed:_models.img] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.name_label.text = _models.type_name;
}

-(UIImageView *)img_imageView{
    if (!_img_imageView) {
        _img_imageView = [UIImageView new];
        _img_imageView.userInteractionEnabled = YES;
    }
    return _img_imageView;
}

-(UILabel *)name_label{
    if (!_name_label) {
        _name_label = tfy_label();
        _name_label.tfy_textcolor(@"212121", 1).tfy_fontSize(15).tfy_alignment(0);
        
    }
    return _name_label;
}

@end
