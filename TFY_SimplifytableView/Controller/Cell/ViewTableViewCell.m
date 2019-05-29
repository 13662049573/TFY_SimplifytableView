//
//  ViewTableViewCell.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ViewTableViewCell.h"

@interface ViewTableViewCell ()
@property(nonatomic , strong)UILabel *title_label;
@end


@implementation ViewTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.title_label];
        self.title_label.tfy_LeftSpace(25).tfy_TopSpace(0).tfy_RightSpace(25).tfy_HeightAuto();
    }
    return self;
}

-(void)setModels:(Prod_list *)models{
    _models = models;
    
    self.title_label.text = _models.title;
}

-(UILabel *)title_label{
    if (!_title_label) {
        _title_label = [UILabel tfy_textcolor:[UIColor tfy_colorWithHex:@"212121"] FontOfSize:15 Alignment:1];
        _title_label.numberOfLines = 0;
    }
    return _title_label;
}

@end
