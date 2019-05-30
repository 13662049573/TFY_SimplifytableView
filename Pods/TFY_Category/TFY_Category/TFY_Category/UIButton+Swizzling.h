//
//  UIButton+Swizzling.h
//  PanGesture
//
//  Created by 田风有 on 2017/7/7.
//  Copyright © 2017年 田风有. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TFY_ButtonPosition) {
    
    /** 图片在左，文字在右，默认 */
    TFY_ButtonPositionImageLeft_titleRight = 0,
    /** 图片在右，文字在左 */
    TFY_ButtonPositionImageRight_titleLeft = 1,
    /** 图片在上，文字在下 */
    TFY_ButtonPositionImageTop_titleBottom = 2,
    /** 图片在下，文字在上 */
    TFY_ButtonPositionImageBottom_titleTop = 3,
};

@interface UIButton (Swizzling)

/** 按钮默认状态文字 */
@property (nonatomic, copy) NSString *tfy_nTitle;

/** 按钮高亮状态文字 */
@property (nonatomic, copy) NSString *tfy_hTitle;

/** 按钮选中状态文字 */
@property (nonatomic, copy) NSString *tfy_sTitle;


/** 按钮默认状态文字颜色 */
@property (nonatomic, strong) UIColor *tfy_title_nColor;

/** 按钮高亮状态文字颜色 */
@property (nonatomic, strong) UIColor *tfy_title_hColor;

/** 按钮选中状态文字颜色 */
@property (nonatomic, strong) UIColor *tfy_title_sColor;


/** 按钮默认状态图片 */
@property (nonatomic, strong) UIImage *tfy_nImage;

/** 按钮高亮状态图片 */
@property (nonatomic, strong) UIImage *tfy_hImage;

/** 按钮选中状态图片 */
@property (nonatomic, strong) UIImage *tfy_sImage;


/** 设置按钮字号 */
@property (nonatomic, strong) UIFont *tfy_titleFont;


/** 按钮圆角半径 */
- (void)tfy_radius:(CGFloat)radius;


/** 设置按钮左对齐 */
- (void)tfy_leftAlignment;

/** 设置按钮中心对齐 */
- (void)tfy_centerAlignment;

/** 设置按钮右对齐 */
- (void)tfy_rightAlignment;

/** 设置按钮上对齐 */
- (void)tfy_topAlignment;

/** 设置按钮下对齐 */
- (void)tfy_bottomAlignment;

/** 设置点击事件 */
- (void)tfy_addTarget:(id)target selector:(SEL)selector;

/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing   spacing 图片和文字的间隔
 */
-(void)tfy_layouEdgeInsetsPosition:(TFY_ButtonPosition)postion spacing:(CGFloat)spacing;

/**
 *  利用运行时自由设置UIButton的titleLabel和imageView的显示位置
 */

/** 设置按钮图片控件位置 */
@property (nonatomic, assign) CGRect tfy_imageRect;

/** 设置按钮图片控件位置 */
@property (nonatomic, assign) CGRect tfy_titleRect;

/** 设置按钮图片控件位置 */
- (void)tfy_layoutTitleRect:(CGRect )titleRect imageRect:(CGRect )imageRect;
/**
 *  带有uiiinage 图片方法
 */
+(UIButton*)tfy_createButtonWithTarget:(id)target Selector:(SEL)selector Image:(NSString *)image ImagePressed:(NSString *)imagePressed;
/**
 *  title 按钮文字  color a颜色 font 大小  是否居中 Integer 0 居中 1 向左 2 向右
 */
+(UIButton *)tfy_createButtonWithTitle:(NSString *)title titleColor:(UIColor *)color font:(CGFloat)font Alignment:(NSInteger )Integer Target:(id)target Selector:(SEL)selector;
/**
 *  title 按钮文字  color a颜色 font 大小  是否居中 Integer 0 居中 1 向左 2 向右  TFY_ButtonPosition 图片的位置方法 space 图片距离
 */
+(UIButton *)tfy_createButtonImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font Alignment:(NSInteger )Integer EdgeInsetsStyle:(TFY_ButtonPosition)style imageTitleSpace:(CGFloat)space target:(id)target action:(SEL)action;

@end
