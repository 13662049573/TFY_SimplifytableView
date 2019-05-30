//
//  UIButton+Swizzling.m
//  PanGesture
//
//  Created by 田风有 on 2017/7/7.
//  Copyright © 2017年 田风有. All rights reserved.
//

#import "UIButton+Swizzling.h"
#import <objc/runtime.h>

@implementation UIButton (Swizzling)

-(CGRect)tfy_titleRectForContentRect:(CGRect)contentRect{
    if (!CGRectIsEmpty(self.tfy_titleRect) && !CGRectEqualToRect(self.tfy_titleRect, CGRectZero)) {
        return self.tfy_titleRect;
    }
    return [self tfy_titleRectForContentRect:contentRect];
}

- (CGRect)tfy_imageRectForContentRect:(CGRect)contentRect {
    
    if (!CGRectIsEmpty(self.tfy_imageRect) && !CGRectEqualToRect(self.tfy_imageRect, CGRectZero)) {
        return self.tfy_imageRect;
    }
    return [self tfy_imageRectForContentRect:contentRect];
}

- (void)setTfy_nTitle:(NSString *)tfy_nTitle {
    
    [self setTitle:tfy_nTitle forState:UIControlStateNormal];
}

- (NSString *)tfy_nTitle {
    
    return [self titleForState:UIControlStateNormal];
}

- (void)setTfy_hTitle:(NSString *)tfy_hTitle {
    
    [self setTitle:tfy_hTitle forState:UIControlStateHighlighted];
}

- (NSString *)tfy_hTitle {
    
    return [self titleForState:UIControlStateHighlighted];
}

- (void)setTfy_sTitle:(NSString *)tfy_sTitle {
    
    [self setTitle:tfy_sTitle forState:UIControlStateSelected];
}

- (NSString *)tfy_sTitle {
    
    return [self titleForState:UIControlStateSelected];
}

- (void)setTfy_title_nColor:(UIColor *)tfy_title_nColor {
    
    [self setTitleColor:tfy_title_nColor forState:UIControlStateNormal];
}

- (UIColor *)tfy_title_nColor {
    
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setTfy_title_hColor:(UIColor *)tfy_title_hColor {
    
    [self setTitleColor:tfy_title_hColor forState:UIControlStateHighlighted];
}

- (UIColor *)tfy_title_hColor {
    
    return [self titleColorForState:UIControlStateHighlighted];
}

- (void)setTfy_title_sColor:(UIColor *)tfy_title_sColor {
    
    [self setTitleColor:tfy_title_sColor forState:UIControlStateSelected];
}

- (UIColor *)tfy_title_sColor {
    
    return [self titleColorForState:UIControlStateSelected];
}

- (void)setTfy_nImage:(UIImage *)tfy_nImage {
    
    [self setImage:tfy_nImage forState:UIControlStateNormal];
}

- (UIImage *)tfy_nImage {
    
    return [self imageForState:UIControlStateNormal];
}

- (void)setTfy_hImage:(UIImage *)tfy_hImage {
    
    [self setImage:tfy_hImage forState:UIControlStateHighlighted];
}

- (UIImage *)tfy_hImage {
    
    return [self imageForState:UIControlStateHighlighted];
}

- (void)setTfy_sImage:(UIImage *)tfy_sImage {
    
    [self setImage:tfy_sImage forState:UIControlStateSelected];
}

- (UIImage *)tfy_sImage {
    
    return [self imageForState:UIControlStateSelected];
}

- (void)setTfy_titleFont:(UIFont *)tfy_titleFont {
    
    self.titleLabel.font = tfy_titleFont;
}

- (UIFont *)tfy_titleFont {
    
    return self.titleLabel.font;
}

- (void)tfy_radius:(CGFloat)radius {
    
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
}

- (void)tfy_leftAlignment {
    
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

- (void)tfy_centerAlignment {
    
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}

- (void)tfy_rightAlignment {
    
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)tfy_topAlignment {
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
}

- (void)tfy_bottomAlignment {
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
}

+(UIButton*)tfy_createButtonWithTarget:(id)target Selector:(SEL)selector Image:(NSString *)image ImagePressed:(NSString *)imagePressed{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tfy_nImage = [UIImage imageNamed:image];
    button.tfy_hImage = [UIImage imageNamed:imagePressed];
    [button tfy_addTarget:target selector:selector];
    return button;
}

+(UIButton *)tfy_createButtonWithTitle:(NSString *)title titleColor:(UIColor *)color font:(CGFloat)font Alignment:(NSInteger )Integer Target:(id)target Selector:(SEL)selector{
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tfy_nTitle = title;
    button.tfy_title_nColor = color;
    button.tfy_titleFont = [UIFont systemFontOfSize:font];
    switch (Integer) {
        case 0:
            button.contentHorizontalAlignment =UIControlContentHorizontalAlignmentCenter;
            break;
        case 1:
            button.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
            break;
        case 2:
            button.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
            break;
        case 3:
            button.contentHorizontalAlignment =UIControlContentHorizontalAlignmentFill;
            break;
        default:
            break;
    }
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button tfy_addTarget:target selector:selector];
    return button;
}
/**
 *  title 按钮文字  color a颜色 font 大小  是否居中 Integer 0 居中 1 向左 2 向右  TFY_ButtonPosition 图片的位置方法 space 图片距离
 */
+(UIButton *)tfy_createButtonImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font Alignment:(NSInteger )Integer EdgeInsetsStyle:(TFY_ButtonPosition)style imageTitleSpace:(CGFloat)space target:(id)target action:(SEL)action{
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    if (imageName)
    {
        [btn setTfy_nImage:[UIImage imageNamed:imageName]];
    }
    
    if (font)
    {
        btn.tfy_titleFont = font;
    }
    
    if (title)
    {
        [btn setTfy_nTitle:title];
    }
    if (color)
    {
        [btn setTfy_title_nColor:color];
    }
    if (target&&action)
    {
        [btn tfy_addTarget:target selector:action];
    }
    switch (Integer) {
        case 0:
            btn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentCenter;
            break;
        case 1:
            btn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
            break;
        case 2:
            btn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
            break;
        case 3:
            btn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentFill;
            break;
        default:
            break;
    }
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [btn tfy_layouEdgeInsetsPosition:style spacing:space];
    return btn;
}

- (void)tfy_addTarget:(id)target selector:(SEL)selector {
    
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

-(void)tfy_layouEdgeInsetsPosition:(TFY_ButtonPosition)postion spacing:(CGFloat)spacing{
    
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
        case TFY_ButtonPositionImageTop_titleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-spacing/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-spacing/2.0, 0);
        }
            break;
        case TFY_ButtonPositionImageLeft_titleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2.0, 0, spacing/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, spacing/2.0, 0, -spacing/2.0);
        }
            break;
        case TFY_ButtonPositionImageBottom_titleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-spacing/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-spacing/2.0, -imageWith, 0, 0);
        }
            break;
        case TFY_ButtonPositionImageRight_titleLeft:
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

#pragma mark - ************* 通过运行时动态添加关联 ******************
//定义关联的Key
static const char * titleRectKey = "titleRectKey";

- (CGRect)tfy_titleRect {
    
    return [objc_getAssociatedObject(self, titleRectKey) CGRectValue];
}

- (void)setTfy_titleRect:(CGRect)tfy_titleRect {
    
    objc_setAssociatedObject(self, titleRectKey, [NSValue valueWithCGRect:tfy_titleRect], OBJC_ASSOCIATION_RETAIN);
}

//定义关联的Key
static const char * imageRectKey = "imageRectKey";

- (CGRect)tfy_imageRect {
    
    NSValue * rectValue = objc_getAssociatedObject(self, imageRectKey);
    
    return [rectValue CGRectValue];
}

- (void)setTfy_imageRect:(CGRect)tfy_imageRect {
    
    objc_setAssociatedObject(self, imageRectKey, [NSValue valueWithCGRect:tfy_imageRect], OBJC_ASSOCIATION_RETAIN);
}

- (void)tfy_layoutTitleRect:(CGRect)titleRect imageRect:(CGRect)imageRect {
    
    self.tfy_titleRect = titleRect;
    self.tfy_imageRect = imageRect;
}


@end
