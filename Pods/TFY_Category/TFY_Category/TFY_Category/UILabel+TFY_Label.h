//
//  UILabel+TFY_Label.h
//  TFY_CHESHI
//
//  Created by 田风有 on 2018/8/16.
//  Copyright © 2018年 田风有. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <UIKit/UIKit.h>

@protocol TFY_RichTextDelegate <NSObject>
@optional
/**
 *  RichTextDelegate  string  点击的字符串  range   点击的字符串range  index   点击的字符在数组中的index
 */
- (void)tfy_didClickRichText:(NSString *)string range:(NSRange)range index:(NSInteger)index;
@end

@interface UILabel (TFY_Label)

/**
 *  是否打开点击效果，默认是打开
 */
@property (nonatomic, assign) BOOL tfy_enabledClickEffect;

/**
 *  点击效果颜色 默认lightGrayColor
 */
@property (nonatomic, strong) UIColor *tfy_clickEffectColor;

/**
 *  给文本添加Block点击事件回调 strings  需要添加的字符串数组  clickAction 点击事件回调
 */
- (void)tfy_clickRichTextWithStrings:(NSArray <NSString *> *)strings clickAction:(void (^) (NSString *string, NSRange range, NSInteger index))clickAction;

/**
 *  给文本添加点击事件delegate回调 strings  需要添加的字符串数组  delegate 富文本代理
 */
- (void)tfy_clickRichTextWithStrings:(NSArray <NSString *> *)strings delegate:(id <TFY_RichTextDelegate> )delegate;
/**
 *  color 添加颜色  siz 字体大小  index  0 居中 1 向左，2 向右
 */
+(UILabel *)tfy_textcolor:(UIColor *)color FontOfSize:(CGFloat)siz Alignment:(NSInteger)index;
@end
