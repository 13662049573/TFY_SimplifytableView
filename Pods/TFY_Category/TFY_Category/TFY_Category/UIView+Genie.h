//
//  UIView+Genie.h
//  BCGenieEffect
//
//  Created by Bartosz Ciechanowski on 23.12.2012.
//  Copyright (c) 2012 Bartosz Ciechanowski. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <UIKit/UIKit.h>
//动画需要的枚举
typedef NS_ENUM(NSUInteger, TFYRectEdge) {
    TFYRectEdgeTop    = 0,
    TFYRectEdgeLeft   = 1,
    TFYRectEdgeBottom = 2,
    TFYRectEdgeRight  = 3
};
//添加阴影需要的枚举
typedef enum :NSInteger{
    
    TFY_ShadowPathLeft,
    
    TFY_ShadowPathRight,
    
    TFY_ShadowPathTop,
    
    TFY_ShadowPathBottom,
    
    TFY_ShadowPathNoTop,
    
    TFY_ShadowPathAllSide
    
} TFY_ShadowPathSide;
//添加边框的枚举
typedef NS_OPTIONS(NSUInteger, UIBorderSideType) {
    UIBorderSideTypeAll  = 0,
    UIBorderSideTypeTop = 1 << 0,
    UIBorderSideTypeBottom = 1 << 1,
    UIBorderSideTypeLeft = 1 << 2,
    UIBorderSideTypeRight = 1 << 3,
};
@interface UIView (Genie)
@property CGPoint tfy_startPoint;
@property CGPoint tfy_endPoint;
/**
 *  定义每个渐变颜色的CGColorRef对象数组
 */
@property(nullable, copy) NSArray *tfy_colors;
/**
 *  NSNumber对象的可选数组，用于定义每个对象的位置梯度停止为[0,1]范围内的值。值必须是单调增加。如果给出一个nil数组，则停止假设在[0,1]范围内均匀分布。渲染时，颜色在被存储之前映射到输出颜色空间插值。默认为零。动画。
 */
@property(nullable, copy) NSArray<NSNumber *> *tfy_locations;
/*
 * 在动画完成视图的变换将更改以匹配目标的矩形，即
 *视图的转换（因此框架）会改变，但是边界和中心不会改变。*/

- (void)tfy_genieInTransitionWithDuration:(NSTimeInterval)duration destinationRect:(CGRect)destRect destinationEdge:(TFYRectEdge)destEdge completion:(void (^_Nonnull)(void))completion;
/*
 * 在动画完成视图的变换将改变CGAffineTransformIdentity。
 */

- (void)tfy_genieOutTransitionWithDuration:(NSTimeInterval)duration startRect:(CGRect)startRect startEdge:(TFYRectEdge)startEdge completion:(void (^_Nonnull)(void))completion;
/**
 *  设置view指定位置的边框 color 边框颜色  borderWidth  边框宽度   borderType  边框类型
 */
-(UIView *_Nonnull)tfy_borderForColor:(UIColor *_Nonnull)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;
/**
 *
 *设置一个四角圆角 radius 圆角半径  color  圆角背景色
 */
- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *_Nonnull)color;

/**
 *
 *设置一个普通圆角 radius  圆角半径 color   圆角背景色 corners 圆角位置
 */
- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *_Nonnull)color corners:(UIRectCorner)corners;
/**
 *
 *设置一个带边框的圆角 cornerRadii 圆角半径cornerRadii color       圆角背景色  corners     圆角位置  borderColor 边框颜色 borderWidth 边框线宽
 */
- (void)tfy_cornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *_Nonnull)color corners:(UIRectCorner)corners borderColor:(UIColor *_Nonnull)borderColor borderWidth:(CGFloat)borderWidth;
/**
 *
 */
+ (UIView *_Nullable)tfy_gradientViewWithColors:(NSArray<UIColor *> *_Nullable)colors locations:(NSArray<NSNumber *> *_Nullable)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)tfy_setGradientBackgroundWithColors:(NSArray<UIColor *> *_Nullable)colors locations:(NSArray<NSNumber *> *_Nullable)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
/**
 * 添加四边阴影效果
 */
- (void)tfy_addShadowToView:(UIView *_Nonnull)theView withColor:(UIColor *_Nonnull)theColor;
/**
 *  添加单边阴影效果
 */
-(void)tfy_addShadowhalfView:(UIView *_Nonnull)theView withColor:(UIColor *_Nonnull)theColor;
/**
 * 添加阴影 shadowColor 阴影颜色 shadowOpacity 阴影透明度，默认0  shadowRadius  阴影半径，默认3 shadowPathSide 设置哪一侧的阴影，shadowPathWidth 阴影的宽度，
 */
-(void)tfy_SetShadowPathWith:(UIColor *_Nonnull)shadowColor shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius shadowSide:(TFY_ShadowPathSide)shadowPathSide shadowPathWidth:(CGFloat)shadowPathWidth;

-(void)tfy_setShadow:(CGSize)size shadowOpacity:(CGFloat)opacity shadowRadius:(CGFloat)radius shadowColor:(UIColor *_Nonnull)color;
@end


@interface CALayer (TFY_Rounded)

@property (nonatomic, strong) UIImage * _Nonnull tfy_contentImage;//contents的便捷设置

/**如下分别对应UIView的相应API*/

- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *_Nonnull)color;

- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *_Nonnull)color corners:(UIRectCorner)corners;

- (void)tfy_cornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *_Nonnull)color corners:(UIRectCorner)corners borderColor:(UIColor *_Nonnull)borderColor borderWidth:(CGFloat)borderWidth;

@end
