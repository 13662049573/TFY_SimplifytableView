//
//  ViewHerderView.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ViewHerderView.h"

@interface ViewHerderView ()
@property(nonatomic , strong)UILabel *title_label;

@property(nonatomic , strong)UIImageView *icon_imageView;
@end

@implementation ViewHerderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor tfy_colorWithHex:@"F6F7FD"];
        
        [self addSubview:self.icon_imageView];
        self.icon_imageView.tfy_LeftSpace(25).tfy_CenterY(0).tfy_size(35, 35);
        
        [self addSubview:self.title_label];
        self.title_label.tfy_LeftSpaceToView(10, self.icon_imageView).tfy_TopSpace(0).tfy_BottomSpace(0).tfy_RightSpace(25);
    }
    return self;
}

-(void)setModels:(Data *)models{
    _models = models;

    self.icon_imageView.image = [[UIImage imageNamed:_models.user_avatar] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.title_label.text = _models.nick_name;
}

-(UIImageView *)icon_imageView{
    if (!_icon_imageView) {
        _icon_imageView = tfy_imageView();
        _icon_imageView.tfy_cornerRadius(15);
    }
    return _icon_imageView;
}

-(UILabel *)title_label{
    if (!_title_label) {
        _title_label = tfy_label();
        _title_label.tfy_textcolor(@"2960DB", 1).tfy_fontSize(12).tfy_alignment(0);
    }
    return _title_label;
}

@end
