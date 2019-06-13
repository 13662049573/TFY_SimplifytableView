//
//  UIImageView+TFY_Chain.m
//  TFY_Category
//
//  Created by 田风有 on 2019/6/6.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UIImageView+TFY_Chain.h"

#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@implementation UIImageView (TFY_Chain)

UIImageView *tfy_imageView(void){
    return [UIImageView new];
}

-(UIImageView *(^)(NSString *image_str))tfy_imge{
    WSelf(myself);
    return ^(NSString *str){
        myself.image = [[UIImage imageNamed:str] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [myself setUserInteractionEnabled:YES];
        return myself;
    };
}

-(UIImageView *(^)(CGFloat cornerRadius))tfy_cornerRadius{
    WSelf(myself);
    return ^(CGFloat cornerRadius){
        myself.layer.cornerRadius = cornerRadius;
        myself.layer.masksToBounds = YES;
        return myself;
    };
}

-(UIImageView *(^)(CGFloat borderWidth, NSString *color))tfy_borders{
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
-(UIImageView *(^)(NSString *color_str, CGFloat shadowRadius))tfy_bordersShadow{
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

-(UIImageView *(^)(NSString *HexString,CGFloat alpha))tfy_backgroundColor{
    WSelf(myself);
    return ^(NSString *HexString,CGFloat alpha){
        [myself setBackgroundColor:[myself btncolorWithHexString:HexString alpha:alpha]];
        [myself setUserInteractionEnabled:YES];
        return myself;
    };
}

-(UIImageView *(^)(id object, SEL action))tfy_action{
    WSelf(myself);
    return ^(id object, SEL action){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:object action:action];
        [myself addGestureRecognizer:tap];
        [myself setUserInteractionEnabled:YES];
        return myself;
    };
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
