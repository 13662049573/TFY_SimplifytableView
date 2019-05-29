//
//  UIView+UIViewController.h
//  Installment
//
//  Created by 田风有 on 2017/3/30.
//  Copyright © 2018年 田风有. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (UIViewController)

/**
 *  获取当前控制器
 *
 *
 */
- (UIViewController *)viewController;

/**
 *  获取当前navigationController
 *
 *
 */
- (UINavigationController *)navigationController;
/**
 *  获取当前tabBarController
 *
 *  
 */
- (UITabBarController *)tabBarController;
@end
NS_ASSUME_NONNULL_END
