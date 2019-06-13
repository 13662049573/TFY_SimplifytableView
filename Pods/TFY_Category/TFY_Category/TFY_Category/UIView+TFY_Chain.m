//
//  UIView+TFY_Chain.m
//  TFY_Category
//
//  Created by 田风有 on 2019/6/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UIView+TFY_Chain.h"
#import <objc/runtime.h>

NSString const *UIView_badgeKey = @"UIView_badgeKey";
NSString const *UIView_badgeBGColorKey = @"UIView_badgeBGColorKey";
NSString const *UIView_badgeTextColorKey = @"UIView_badgeTextColorKey";
NSString const *UIView_badgeFontKey = @"UIView_badgeFontKey";
NSString const *UIView_badgePaddingKey = @"UIView_badgePaddingKey";
NSString const *UIView_badgeMinSizeKey = @"UIView_badgeMinSizeKey";
NSString const *UIView_badgeOriginXKey = @"UIView_badgeOriginXKey";
NSString const *UIView_badgeOriginYKey = @"UIView_badgeOriginYKey";
NSString const *UIView_shouldHideBadgeAtZeroKey = @"UIView_shouldHideBadgeAtZeroKey";
NSString const *UIView_shouldAnimateBadgeKey = @"UIView_shouldAnimateBadgeKey";
NSString const *UIView_badgeValueKey = @"UIView_badgeValueKey";

@implementation UIView (TFY_Chain)

-(UILabel *)tfy_bgdge{
    return objc_getAssociatedObject(self, &UIView_badgeKey);
}

-(void)setTfy_bgdge:(UILabel * _Nonnull)tfy_bgdge{
    objc_setAssociatedObject(self, &UIView_badgeKey, tfy_bgdge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)tfy_badgeValue{
    return objc_getAssociatedObject(self, &UIView_badgeValueKey);
}

-(void)setTfy_badgeValue:(NSString * _Nonnull)tfy_badgeValue{
    objc_setAssociatedObject(self, &UIView_badgeValueKey, tfy_badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!tfy_badgeValue || [tfy_badgeValue isEqualToString:@""] || ([tfy_badgeValue isEqualToString:@"0"] && self.tfy_shouldHideBadgeAtZero)) {
        [self removeBadge];
    }
    else if (!self.tfy_bgdge){
        self.tfy_bgdge = [[UILabel alloc] initWithFrame:CGRectMake(self.tfy_badgeOriginX, self.tfy_badgeOriginY, 20, 20)];
        self.tfy_bgdge.textColor = self.tfy_badgeTextColor;
        self.tfy_bgdge.backgroundColor = self.tfy_badgeBGColor;
        self.tfy_bgdge.font = self.tfy_badgeFont;
        self.tfy_bgdge.textAlignment = NSTextAlignmentCenter;
        [self badgeInit];
        [self addSubview:self.tfy_bgdge];
        [self updateBadgeValueAnimated:NO];
    }
    else{
        [self updateBadgeValueAnimated:YES];
    }
}

-(UIColor *)tfy_badgeBGColor{
    return objc_getAssociatedObject(self, &UIView_badgeBGColorKey);
}

-(void)setTfy_badgeBGColor:(UIColor * _Nonnull)tfy_badgeBGColor{
    objc_setAssociatedObject(self, &UIView_badgeBGColorKey, tfy_badgeBGColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(UIColor *)tfy_badgeTextColor{
    return objc_getAssociatedObject(self, &UIView_badgeTextColorKey);
}

-(void)setTfy_badgeTextColor:(UIColor * _Nonnull)tfy_badgeTextColor{
    objc_setAssociatedObject(self, &UIView_badgeTextColorKey, tfy_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(UIFont *)tfy_badgeFont{
    return objc_getAssociatedObject(self, &UIView_badgeFontKey);
}

-(void)setTfy_badgeFont:(UIFont * _Nonnull)tfy_badgeFont{
    objc_setAssociatedObject(self, &UIView_badgeFontKey, tfy_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self refreshBadge];
    }
}

-(CGFloat)tfy_badgePadding{
    NSNumber *number = objc_getAssociatedObject(self, &UIView_badgePaddingKey);
    return number.floatValue;
}

-(void)setTfy_badgePadding:(CGFloat)tfy_badgePadding{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgePadding];
    objc_setAssociatedObject(self, &UIView_badgePaddingKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat)tfy_badgeMinSize{
    NSNumber *number = objc_getAssociatedObject(self, &UIView_badgeMinSizeKey);
    return number.floatValue;
}

-(void)setTfy_badgeMinSize:(CGFloat)tfy_badgeMinSize{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgeMinSize];
    objc_setAssociatedObject(self, &UIView_badgeMinSizeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat)tfy_badgeOriginX{
    NSNumber *number = objc_getAssociatedObject(self, &UIView_badgeOriginXKey);
    return number.floatValue;
}

-(void)setTfy_badgeOriginX:(CGFloat)tfy_badgeOriginX{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgeOriginX];
    objc_setAssociatedObject(self, &UIView_badgeOriginXKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat)tfy_badgeOriginY{
    NSNumber *number = objc_getAssociatedObject(self, &UIView_badgeOriginYKey);
    return number.floatValue;
}

-(void)setTfy_badgeOriginY:(CGFloat)tfy_badgeOriginY{
    NSNumber *number = [NSNumber numberWithDouble:tfy_badgeOriginY];
    objc_setAssociatedObject(self, &UIView_badgeOriginYKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_bgdge) {
        [self updateBadgeFrame];
    }
}

-(BOOL)tfy_shouldHideBadgeAtZero{
    NSNumber *number = objc_getAssociatedObject(self, &UIView_shouldHideBadgeAtZeroKey);
    return number.boolValue;
}

-(void)setTfy_shouldHideBadgeAtZero:(BOOL)tfy_shouldHideBadgeAtZero{
    NSNumber *number = [NSNumber numberWithBool:tfy_shouldHideBadgeAtZero];
    objc_setAssociatedObject(self, &UIView_shouldHideBadgeAtZeroKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)tfy_shouldAnimateBadge{
    NSNumber *number = objc_getAssociatedObject(self, &UIView_shouldAnimateBadgeKey);
    return number.boolValue;
}

-(void)setTfy_shouldAnimateBadge:(BOOL)tfy_shouldAnimateBadge{
    NSNumber *number = [NSNumber numberWithBool:tfy_shouldAnimateBadge];
    objc_setAssociatedObject(self, &UIView_shouldAnimateBadgeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)removeBadge{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tfy_bgdge.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.tfy_bgdge removeFromSuperview];
    }];
}

-(void)badgeInit{
    
    self.tfy_badgeBGColor = [UIColor redColor];
    self.tfy_badgeTextColor = [UIColor whiteColor];
    self.tfy_badgeFont = [UIFont systemFontOfSize:12];
    self.tfy_badgePadding = 6;
    self.tfy_badgeMinSize = 8;
    self.tfy_badgeOriginX = self.frame.size.width - self.tfy_bgdge.frame.size.width/2;
    self.tfy_badgeOriginY = -4;
    self.tfy_shouldHideBadgeAtZero = YES;
    self.tfy_shouldAnimateBadge = YES;
    self.clipsToBounds = NO;
}

-(void)updateBadgeValueAnimated:(BOOL)animated{
    
    if (animated && self.tfy_shouldAnimateBadge && ![self.tfy_bgdge.text isEqualToString:self.tfy_badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4f :1.3f :1.f :1.f]];
        [self.tfy_bgdge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    self.tfy_bgdge.text = self.tfy_badgeValue;

    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        [self updateBadgeFrame];
    }];
}

-(void)updateBadgeFrame{
    
    CGSize expectedLabelSize = [self badgeExpectedSize];
    CGFloat minHeight = expectedLabelSize.height;
    minHeight = (minHeight < self.tfy_badgeMinSize) ? self.tfy_badgeMinSize : expectedLabelSize.height;
    CGFloat minWidth = expectedLabelSize.width;
    CGFloat padding = self.tfy_badgePadding;
    minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
    self.tfy_bgdge.frame = CGRectMake(self.tfy_badgeOriginX, self.tfy_badgeOriginY, minWidth + padding, minHeight + padding);
    self.tfy_bgdge.layer.cornerRadius = (minHeight + padding) / 2;
    self.tfy_bgdge.layer.masksToBounds = YES;
}

-(CGSize)badgeExpectedSize
{
    UILabel *frameLabel = [self duplicateLabel:self.tfy_bgdge];
    [frameLabel sizeToFit];
    
    CGSize expectedLabelSize = frameLabel.frame.size;
    return expectedLabelSize;
}

-(UILabel *)duplicateLabel:(UILabel *)labelToCopy{
    
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    return duplicateLabel;
}

-(void)refreshBadge{

    self.tfy_bgdge.textColor = self.tfy_badgeTextColor;
    self.tfy_bgdge.backgroundColor = self.tfy_badgeBGColor;
    self.tfy_bgdge.font = self.tfy_badgeFont;
}


- (UIViewController *_Nonnull)viewController
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    } while (next);
    return nil;
    
}

- (UINavigationController *_Nonnull)navigationController
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)next;
            
        }
        next = next.nextResponder;
    } while (next);
    return nil;
    
}
- (UITabBarController *_Nonnull)tabBarController
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UITabBarController class]]) {
            return (UITabBarController *)next;
        }
        next = next.nextResponder;
    } while (next);
    return nil;
}

/**
 *  设置view指定位置的边框 color 边框颜色  borderWidth  边框宽度   borderType  边框类型
 */
-(UIView *_Nonnull)tfy_borderForColor:(UIColor *_Nonnull)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType{
    if (borderType == UIBorderSideTypeAll) {
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = color.CGColor;
        return self;
    }
    /// 左侧
    if (borderType & UIBorderSideTypeLeft) {
        /// 左侧线路径
        [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(0.f, 0.f) toPoint:CGPointMake(0.0f, self.frame.size.height) color:color borderWidth:borderWidth]];
    }
    
    /// 右侧
    if (borderType & UIBorderSideTypeRight) {
        /// 右侧线路径
        [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(self.frame.size.width, 0.0f) toPoint:CGPointMake( self.frame.size.width, self.frame.size.height) color:color borderWidth:borderWidth]];
    }
    
    /// top
    if (borderType & UIBorderSideTypeTop) {
        /// top线路径
        [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f, 0.0f) toPoint:CGPointMake(self.frame.size.width, 0.0f) color:color borderWidth:borderWidth]];
    }
    
    /// bottom
    if (borderType & UIBorderSideTypeBottom) {
        /// bottom线路径
        [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f, self.frame.size.height) toPoint:CGPointMake( self.frame.size.width, self.frame.size.height) color:color borderWidth:borderWidth]];
    }
    
    return self;
}

- (CAShapeLayer *)addLineOriginPoint:(CGPoint)p0 toPoint:(CGPoint)p1 color:(UIColor *)color borderWidth:(CGFloat)borderWidth {
    /// 线的路径
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:p0];
    [bezierPath addLineToPoint:p1];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor  = [UIColor clearColor].CGColor;
    /// 添加路径
    shapeLayer.path = bezierPath.CGPath;
    /// 线宽度
    shapeLayer.lineWidth = borderWidth;
    return shapeLayer;
}

/**
 * 添加阴影 shadowColor 阴影颜色 shadowOpacity 阴影透明度，默认0  shadowRadius  阴影半径，默认3 shadowPathSide 设置哪一侧的阴影，shadowPathWidth 阴影的宽度，
 */
-(void)tfy_SetShadowPathWith:(UIColor *_Nonnull)shadowColor shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius shadowSide:(TFY_ShadowPathSide)shadowPathSide shadowPathWidth:(CGFloat)shadowPathWidth{
    
    self.layer.masksToBounds = NO;
    
    self.layer.shadowColor = shadowColor.CGColor;
    
    self.layer.shadowOpacity = shadowOpacity;
    
    self.layer.shadowRadius =  shadowRadius;
    
    self.layer.shadowOffset = CGSizeZero;
    CGRect shadowRect;
    
    CGFloat originX = 0;
    
    CGFloat originY = 0;
    
    CGFloat originW = self.bounds.size.width;
    
    CGFloat originH = self.bounds.size.height;
    
    
    switch (shadowPathSide) {
        case TFY_ShadowPathTop:
            shadowRect  = CGRectMake(originX, originY - shadowPathWidth/2, originW,  shadowPathWidth);
            break;
        case TFY_ShadowPathBottom:
            shadowRect  = CGRectMake(originX, originH -shadowPathWidth/2, originW, shadowPathWidth);
            break;
            
        case TFY_ShadowPathLeft:
            shadowRect  = CGRectMake(originX - shadowPathWidth/2, originY, shadowPathWidth, originH);
            break;
            
        case TFY_ShadowPathRight:
            shadowRect  = CGRectMake(originW - shadowPathWidth/2, originY, shadowPathWidth, originH);
            break;
        case TFY_ShadowPathNoTop:
            shadowRect  = CGRectMake(originX -shadowPathWidth/2, originY +1, originW +shadowPathWidth,originH + shadowPathWidth/2 );
            break;
        case TFY_ShadowPathAllSide:
            shadowRect  = CGRectMake(originX - shadowPathWidth/2, originY - shadowPathWidth/2, originW +  shadowPathWidth, originH + shadowPathWidth);
            break;
    }
    UIBezierPath *path =[UIBezierPath bezierPathWithRect:shadowRect];
    self.layer.shadowPath = path.CGPath;
}
@end
