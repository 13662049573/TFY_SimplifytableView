//
//  UIView+TFY_Chain.h
//  TFY_Category
//
//  Created by 田风有 on 2019/6/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//添加阴影需要的枚举
typedef NS_OPTIONS(NSUInteger, TFY_ShadowPathSide){
    
    TFY_ShadowPathLeft,
    
    TFY_ShadowPathRight,
    
    TFY_ShadowPathTop,
    
    TFY_ShadowPathBottom,
    
    TFY_ShadowPathNoTop,
    
    TFY_ShadowPathAllSide
    
};
//添加边框的枚举
typedef NS_OPTIONS(NSUInteger, UIBorderSideType) {
    UIBorderSideTypeAll  = 0,
    UIBorderSideTypeTop = 1 << 0,
    UIBorderSideTypeBottom = 1 << 1,
    UIBorderSideTypeLeft = 1 << 2,
    UIBorderSideTypeRight = 1 << 3,
};


@interface UIView (TFY_Chain)
/**
 *  初始一个Lable 可以随自己更改
 */
@property(nonatomic,strong)UILabel *tfy_bgdge;
/**
 *  显示的个数
 */
@property(nonatomic,copy)NSString *tfy_badgeValue;
/**
 * 徽章的背景色
 */
@property(nonatomic,strong)UIColor *tfy_badgeBGColor;
/**
 *  徽章的文字颜色
 */
@property(nonatomic,strong)UIColor *tfy_badgeTextColor;
/**
 *  标志字体
 */
@property(nonatomic,strong)UIFont *tfy_badgeFont;
/**
 *  徽章的填充值
 */
@property(nonatomic,assign)CGFloat tfy_badgePadding;
/**
 *  最小尺寸小徽章
 */
@property(nonatomic,assign)CGFloat tfy_badgeMinSize;
/**
 *  X barbuttonitem你选值
 */
@property(nonatomic,assign)CGFloat tfy_badgeOriginX;
/**
 *  Y barbuttonitem你选值
 */
@property(nonatomic,assign)CGFloat tfy_badgeOriginY;
/**
 *  删除徽章时达到零
 */
@property(nonatomic,assign)BOOL tfy_shouldHideBadgeAtZero;
/**
 *  当价值变化时，徽章有一个反弹动画
 */
@property(nonatomic,assign)BOOL tfy_shouldAnimateBadge;
/**
 *  获取当前控制器
 */
- (UIViewController *_Nonnull)viewController;
/**
 *  获取当前navigationController
 */
- (UINavigationController *_Nonnull)navigationController;
/**
 *  获取当前tabBarController
 */
- (UITabBarController *_Nonnull)tabBarController;
/**
 *  设置view指定位置的边框 color 边框颜色  borderWidth  边框宽度   borderType  边框类型
 */
-(UIView *_Nonnull)tfy_borderForColor:(UIColor *_Nonnull)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;
/**
 * 添加阴影 shadowColor 阴影颜色 shadowOpacity 阴影透明度，默认0  shadowRadius  阴影半径，默认3 shadowPathSide 设置哪一侧的阴影，shadowPathWidth 阴影的宽度，
 */
-(void)tfy_SetShadowPathWith:(UIColor *_Nonnull)shadowColor shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius shadowSide:(TFY_ShadowPathSide)shadowPathSide shadowPathWidth:(CGFloat)shadowPathWidth;

@end

NS_ASSUME_NONNULL_END
