//
//  ViewFooderView.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ViewFooderView.h"

@interface ViewFooderView ()
@property(nonatomic , strong)UILabel *title_label;
@end

@implementation ViewFooderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor tfy_colorWithHex:@"F6F7FD"];
        
        [self addSubview:self.title_label];
        self.title_label.tfy_LeftSpace(20).tfy_TopSpace(0).tfy_BottomSpace(0).tfy_RightSpace(20);
    }
    return self;
}

-(void)setModel:(Prod_list *)model{
    _model = model;
    
    self.title_label.text = _model.title;
}

-(UILabel *)title_label{
    if (!_title_label) {
        _title_label = tfy_label();
        _title_label.tfy_textcolor(@"FF4A44", 1).tfy_fontSize([UIFont systemFontOfSize:14]).tfy_alignment(0);
    }
    return _title_label;
}
@end
