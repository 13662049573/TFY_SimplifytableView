//
//  UIButton+TFY_Chain.m
//  TFY_CHESHI
//
//  Created by 田风有 on 2019/6/5.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "UIButton+TFY_Chain.h"

#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation UIButton (TFY_Chain)

/**
 *  按钮初始化
 */
UIButton *tfy_button(void){
    return [UIButton new];
}

/**
 *  文本输入
 */
-(UIButton *(^)(NSString *title_str))tfy_text{
    WSelf(myself);
    return ^(NSString *title_str){
        [myself setTitle:title_str forState:UIControlStateNormal];
        return myself;
    };
}
/**
 *  文本颜色
 */
-(UIButton *(^)(NSString *color_str))tfy_textcolor{
    WSelf(myself);
    return ^(NSString *color_str){
        [myself setTitleColor:[myself btncolorWithHexString:color_str alpha:1] forState:UIControlStateNormal];
        return myself;
    };
}
/**
 *  文本大小
 */
-(UIButton *(^)(CGFloat font))tfy_font{
    WSelf(myself);
    return ^(CGFloat font){
        myself.titleLabel.font = [UIFont systemFontOfSize:font];
        return myself;
    };
}

/**
 *  按钮 title_str 文本文字 color_str 文字颜色  font文字大小
 */
-(UIButton *(^)(NSString *title_str,NSString *color_str,CGFloat font))tfy_title{
    WSelf(myself);
    return ^(NSString *title_str,NSString *color_str,CGFloat font){
        [myself setTitle:title_str forState:UIControlStateNormal];
        [myself setTitleColor:[myself btncolorWithHexString:color_str alpha:1] forState:UIControlStateNormal];
        myself.titleLabel.font = [UIFont systemFontOfSize:font];
        return myself;
    };
}
/**
 *  按钮  HexString 背景颜色 alpha 背景透明度
 */
-(UIButton *(^)(NSString *HexString,CGFloat alpha))tfy_backgroundColor{
    WSelf(myself);
    return ^(NSString *HexString,CGFloat alpha){
        [myself setBackgroundColor:[myself btncolorWithHexString:HexString alpha:alpha]];
        return myself;
    };
}
/**
 *  按钮  alignment 0 左 1 中 2 右
 */
-(UIButton *(^)(NSInteger alignment))tfy_alAlignment{
    WSelf(myself);
    return ^(NSInteger alignment){
        switch (alignment) {
            case 0:
                myself.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
                break;
            case 1:
                myself.contentHorizontalAlignment =UIControlContentHorizontalAlignmentCenter;
                break;
            case 2:
                myself.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
                break;
        }
        return myself;
    };
}
/**
 *  添加四边框和color 颜色  borderWidth 宽度
 */
-(UIButton *(^)(CGFloat borderWidth, NSString *color))tfy_borders{
    WSelf(myself);
    return ^(CGFloat borderWidth, NSString *color){
        myself.layer.borderWidth = borderWidth;
        myself.layer.borderColor = [myself btncolorWithHexString:color alpha:1].CGColor;
        return myself;
    };
}
/**
 *  添加四边 color_str阴影颜色  shadowRadius阴影半径
 */
-(UIButton *(^)(NSString *color_str, CGFloat shadowRadius))tfy_bordersShadow{
    WSelf(myself);
    return ^(NSString *color_str, CGFloat shadowRadius){
        // 阴影颜色
        myself.layer.shadowColor = [myself btncolorWithHexString:color_str alpha:1].CGColor;
        // 阴影偏移，默认(0, -3)
        myself.layer.shadowOffset = CGSizeMake(0,0);
        // 阴影透明度，默认0
        myself.layer.shadowOpacity = 0.5;
        // 阴影半径，默认3
        myself.layer.shadowRadius = shadowRadius;
        
        return myself;
    };
}

/**
 *  按钮  cornerRadius 圆角
 */
-(UIButton *(^)(CGFloat cornerRadius))tfy_cornerRadius{
    WSelf(myself);
    return ^(CGFloat cornerRadius){
        myself.layer.cornerRadius = cornerRadius;
        return myself;
    };
}
/**
 *  按钮  image_str 图片字符串
 */
-(UIButton *(^)(NSString *image_str,UIControlState state))tfy_image{
    WSelf(myself);
    return ^(NSString *image_str,UIControlState state){
        [myself setImage:[[UIImage imageNamed:image_str] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:state];
        return myself;
    };
}
/**
 *  按钮  backimage_str 背景图片
 */
-(UIButton *(^)( NSString *backimage_str,UIControlState state))tfy_backgroundImage{
    WSelf(myself);
    return ^( NSString *backimage_str,UIControlState state){
        [myself setBackgroundImage:[[UIImage imageNamed:backimage_str] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:state];
        return myself;
    };
}
/**
 *  按钮 点击方法
 */
-(UIButton *(^)(id object, SEL action))tfy_action{
    WSelf(myself);
    return ^(id object, SEL action){
        [myself addTarget:object action:action forControlEvents:UIControlEventTouchUpInside];
        return myself;
    };
}
/**
 *  button的大小要大于 图片大小+文字大小+spacing   spacing 图片和文字的间隔
 */
-(void)tfy_layouEdgeInsetsPosition:(ButtonPosition)postion spacing:(CGFloat)spacing{
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    switch (postion) {
        case ButtonPositionImageTop_titleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-spacing/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-spacing/2.0, 0);
        }
            break;
        case ButtonPositionImageLeft_titleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2.0, 0, spacing/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, spacing/2.0, 0, -spacing/2.0);
        }
            break;
        case ButtonPositionImageBottom_titleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-spacing/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-spacing/2.0, -imageWith, 0, 0);
        }
            break;
        case ButtonPositionImageRight_titleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+spacing/2.0, 0, -labelWidth-spacing/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-spacing/2.0, 0, imageWith+spacing/2.0);
        }
            break;
        default:
            break;
    }
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}



-(UIColor *)btncolorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r                       截取的range = (0,2)
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;//     截取的range = (2,2)
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;//     截取的range = (4,2)
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;//将字符串十六进制两位数字转为十进制整数
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}
@end
