//
//  UIImageView+TFY_Chain.h
//  TFY_Category
//
//  Created by 田风有 on 2019/6/6.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (TFY_Chain)
/**
 *  初始化
 */
UIImageView *tfy_imageView(void);
/**
 *  图片赋值字符串
 */
@property(nonatomic,copy,readonly)UIImageView *(^tfy_imge)(NSString *image_str);
/**
 *  图片添加圆角
 */
@property(nonatomic,copy,readonly)UIImageView *(^tfy_cornerRadius)(CGFloat cornerRadius);
/**
 *  添加四边框和color 颜色  borderWidth 宽度
 */
@property(nonatomic,copy,readonly)UIImageView *(^tfy_borders)(CGFloat borderWidth,NSString *color);
/**
 *  添加四边 color_str阴影颜色  shadowRadius阴影半径
 */
@property(nonatomic,copy,readonly)UIImageView *(^tfy_bordersShadow)(NSString *color_str, CGFloat shadowRadius);
/**
 *  图片HexString 背景颜色 alpha 背景透明度
 */
@property(nonatomic,copy,readonly)UIImageView *(^tfy_backgroundColor)(NSString *HexString,CGFloat alpha);
/**
 *  图片 点击方法
 */
@property(nonatomic,copy,readonly)UIImageView *(^tfy_action)(id object, SEL action);

@end

NS_ASSUME_NONNULL_END
