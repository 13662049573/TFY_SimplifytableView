//
//  UIView+Genie.m
//  BCGenieEffect
//
//  Created by Bartosz Ciechanowski on 23.12.2012.
//  Copyright (c) 2012 Bartosz Ciechanowski. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIView+Genie.h"


#pragma mark - Constants


static const double curvesAnimationStart = 0.0;
static const double curvesAnimationEnd = 0.4;
static const double slideAnimationStart = 0.3;
static const double slideAnimationEnd = 1.0;

static const CGFloat kSliceSize = 10.0f; // height/width of a single slice
static const NSTimeInterval kFPS = 60.0; // assumed animation's FPS


static const CGFloat kRenderMargin = 2.0;


#pragma mark - Structs & enums boilerplate

#define isEdgeVertical(d) (!((d) & 1))
#define isEdgeNegative(d) (((d) & 2))
#define axisForEdge(d) ((TFYAxis)isEdgeVertical(d))
#define perpAxis(d) ((TFYAxis)(!(BOOL)d))

typedef NS_ENUM(NSInteger, TFYAxis) {
    TFYAxisX = 0,
    TFYAxisY = 1
};


typedef union TFYPoint
{
    struct { double x, y; }; 
    double v[2];
}
TFYPoint;

static inline TFYPoint TFYPointMake(double x, double y)
{
    TFYPoint p; p.x = x; p.y = y; return p;
}

typedef union TFYTrapezoid {
    struct { TFYPoint a, b, c, d; };
    TFYPoint v[4];
} TFYTrapezoid;


typedef struct TFYSegment {
    TFYPoint a;
    TFYPoint b;
} TFYSegment;

static inline TFYSegment TFYSegmentMake(TFYPoint a, TFYPoint b)
{
    TFYSegment s; s.a = a; s.b = b; return s;
}

typedef TFYSegment TFYBezierCurve;

static const int TFYTrapezoidWinding[4][4] = {
    [TFYRectEdgeTop]    = {0,1,2,3},
    [TFYRectEdgeLeft]   = {2,0,3,1},
    [TFYRectEdgeBottom] = {3,2,1,0},
    [TFYRectEdgeRight]  = {1,3,0,2},
};

@implementation NSObject (_TFYAdd)

+ (void)tfy_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return;
    method_exchangeImplementations(originalMethod, newMethod);
}

- (void)tfy_setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)tfy_getAssociatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)tfy_removeAssociateWithKey:(void *)key {
    objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIImage (TFY_Rounded)

+ (UIImage *)tfy_imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock {
    if (!drawBlock) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    drawBlock(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)tfy_maskRoundCornerRadiusImageWithColor:(UIColor *)color cornerRadii:(CGSize)cornerRadii size:(CGSize)size corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    return [UIImage tfy_imageWithSize:size drawBlock:^(CGContextRef  _Nonnull context) {
        CGContextSetLineWidth(context, 0);
        [color set];
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectInset(rect, -0.3, -0.3)];
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.3, 0.3) byRoundingCorners:corners cornerRadii:cornerRadii];
        [rectPath appendPath:roundPath];
        CGContextAddPath(context, rectPath.CGPath);
        CGContextEOFillPath(context);
        if (!borderColor || !borderWidth) return;
        [borderColor set];
        UIBezierPath *borderOutterPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
        UIBezierPath *borderInnerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:cornerRadii];
        [borderOutterPath appendPath:borderInnerPath];
        CGContextAddPath(context, borderOutterPath.CGPath);
        CGContextEOFillPath(context);
    }];
}

@end



static void *const _TFYMaskCornerRadiusLayerKey = "_TFYMaskCornerRadiusLayerKey";

static NSMutableSet<UIImage *> *maskCornerRaidusImageSet;

@implementation CALayer (TFY_Rounded)

+ (void)load{
    [CALayer tfy_swizzleInstanceMethod:@selector(layoutSublayers) with:@selector(_tfy_layoutSublayers)];
}

- (UIImage *)tfy_contentImage{
    return [UIImage imageWithCGImage:(__bridge CGImageRef)self.contents];
}

- (void)setTfy_contentImage:(UIImage *)tfy_contentImage {
    
    self.contents = (__bridge id)tfy_contentImage.CGImage;
}

- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *)color {
    
    [self tfy_cornerRadius:radius cornerColor:color corners:UIRectCornerAllCorners];
}

- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *)color corners:(UIRectCorner)corners {
    
    [self tfy_cornerRadii:CGSizeMake(radius, radius) cornerColor:color corners:corners borderColor:nil borderWidth:0];
}

- (void)tfy_cornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *)color corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    if (!color) return;
    CALayer *cornerRadiusLayer = [self tfy_getAssociatedValueForKey:_TFYMaskCornerRadiusLayerKey];
    if (!cornerRadiusLayer) {
        cornerRadiusLayer = [CALayer new];
        cornerRadiusLayer.opaque = YES;
        [self tfy_setAssociateValue:cornerRadiusLayer withKey:_TFYMaskCornerRadiusLayerKey];
    }
    if (color) {
        [cornerRadiusLayer tfy_setAssociateValue:color withKey:"_tfy_cornerRadiusImageColor"];
    }else{
        [cornerRadiusLayer tfy_removeAssociateWithKey:"_tfy_cornerRadiusImageColor"];
    }
    [cornerRadiusLayer tfy_setAssociateValue:[NSValue valueWithCGSize:cornerRadii] withKey:"_tfy_cornerRadiusImageRadius"];
    [cornerRadiusLayer tfy_setAssociateValue:@(corners) withKey:"_tfy_cornerRadiusImageCorners"];
    if (borderColor) {
        [cornerRadiusLayer tfy_setAssociateValue:borderColor withKey:"_tfy_cornerRadiusImageBorderColor"];
    }else{
        [cornerRadiusLayer tfy_removeAssociateWithKey:"_tfy_cornerRadiusImageBorderColor"];
    }
    [cornerRadiusLayer tfy_setAssociateValue:@(borderWidth) withKey:"_tfy_cornerRadiusImageBorderWidth"];
    UIImage *image = [self _tfy_getCornerRadiusImageFromSet];
    if (image) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        cornerRadiusLayer.tfy_contentImage = image;
        [CATransaction commit];
    }
}

- (UIImage *)_tfy_getCornerRadiusImageFromSet{
    if (!self.bounds.size.width || !self.bounds.size.height) return nil;
    CALayer *cornerRadiusLayer = [self tfy_getAssociatedValueForKey:_TFYMaskCornerRadiusLayerKey];
    UIColor *color = [cornerRadiusLayer tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageColor"];
    if (!color) return nil;
    CGSize radius = [[cornerRadiusLayer tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageRadius"] CGSizeValue];
    NSUInteger corners = [[cornerRadiusLayer tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageCorners"] unsignedIntegerValue];
    CGFloat borderWidth = [[cornerRadiusLayer tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageBorderWidth"] floatValue];
    UIColor *borderColor = [cornerRadiusLayer tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageBorderColor"];
    if (!maskCornerRaidusImageSet) {
        maskCornerRaidusImageSet = [NSMutableSet new];
    }
    __block UIImage *image = nil;
    [maskCornerRaidusImageSet enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
        CGSize imageSize = [[obj tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageSize"] CGSizeValue];
        UIColor *imageColor = [obj tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageColor"];
        CGSize imageRadius = [[obj tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageRadius"] CGSizeValue];
        NSUInteger imageCorners = [[obj tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageCorners"] unsignedIntegerValue];
        CGFloat imageBorderWidth = [[obj tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageBorderWidth"] floatValue];
        UIColor *imageBorderColor = [obj tfy_getAssociatedValueForKey:"_tfy_cornerRadiusImageBorderColor"];
        BOOL isBorderSame = (CGColorEqualToColor(borderColor.CGColor, imageBorderColor.CGColor) && borderWidth == imageBorderWidth) || (!borderColor && !imageBorderColor) || (!borderWidth && !imageBorderWidth);
        BOOL canReuse = CGSizeEqualToSize(self.bounds.size, imageSize) && CGColorEqualToColor(imageColor.CGColor, color.CGColor) && imageCorners == corners && CGSizeEqualToSize(radius, imageRadius) && isBorderSame;
        if (canReuse) {
            image = obj;
            *stop = YES;
        }
    }];
    if (!image) {
        image = [UIImage tfy_maskRoundCornerRadiusImageWithColor:color cornerRadii:radius size:self.bounds.size corners:corners borderColor:borderColor borderWidth:borderWidth];
        [image tfy_setAssociateValue:[NSValue valueWithCGSize:self.bounds.size] withKey:"_tfy_cornerRadiusImageSize"];
        [image tfy_setAssociateValue:color withKey:"_tfy_cornerRadiusImageColor"];
        [image tfy_setAssociateValue:[NSValue valueWithCGSize:radius] withKey:"_tfy_cornerRadiusImageRadius"];
        [image tfy_setAssociateValue:@(corners) withKey:"_tfy_cornerRadiusImageCorners"];
        if (borderColor) {
            [image tfy_setAssociateValue:color withKey:"_tfy_cornerRadiusImageBorderColor"];
        }
        [image tfy_setAssociateValue:@(borderWidth) withKey:"_tfy_cornerRadiusImageBorderWidth"];
        [maskCornerRaidusImageSet addObject:image];
    }
    return image;
}

#pragma mark - exchage Methods

- (void)_tfy_layoutSublayers {
    
    [self _tfy_layoutSublayers];
    CALayer *cornerRadiusLayer = [self tfy_getAssociatedValueForKey:_TFYMaskCornerRadiusLayerKey];
    if (cornerRadiusLayer) {
        UIImage *aImage = [self _tfy_getCornerRadiusImageFromSet];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        cornerRadiusLayer.tfy_contentImage = aImage;
        cornerRadiusLayer.frame = self.bounds;
        [CATransaction commit];
        [self addSublayer:cornerRadiusLayer];
    }
}

@end

@implementation UIView (Genie)

#pragma mark - publics

- (void)tfy_genieInTransitionWithDuration:(NSTimeInterval)duration destinationRect:(CGRect)destRect destinationEdge:(TFYRectEdge)destEdge completion:(void (^)(void))completion {
    
    [self tfy_genieTransitionWithDuration:duration edge:destEdge destinationRect:destRect reverse:NO completion:completion];
}

- (void)tfy_genieOutTransitionWithDuration:(NSTimeInterval)duration startRect:(CGRect)startRect startEdge:(TFYRectEdge)startEdge completion:(void (^)(void))completion {
    [self tfy_genieTransitionWithDuration:duration edge:startEdge destinationRect:startRect reverse:YES completion:completion];
}

#pragma mark - privates


- (void)tfy_genieTransitionWithDuration:(NSTimeInterval)duration edge:(TFYRectEdge)edge destinationRect:(CGRect)destRect reverse:(BOOL)reverse completion:(void (^)(void))completion
{
    assert(!CGRectIsNull(destRect));
    
    TFYAxis axis = axisForEdge(edge);
    TFYAxis pAxis = perpAxis(axis);
    
    self.transform = CGAffineTransformIdentity;
    
    UIImage *snapshot = [self renderSnapshotWithMarginForAxis:axis];
    NSArray *slices = [self sliceImage:snapshot toLayersAlongAxis:axis];
    
    // Bezier calculations
    CGFloat xInset = axis == TFYAxisY ? -kRenderMargin : 0.0f;
    CGFloat yInset = axis == TFYAxisX ? -kRenderMargin : 0.0f;
    
    CGRect marginedDestRect = CGRectInset(destRect, xInset*destRect.size.width/self.bounds.size.width, yInset*destRect.size.height/self.bounds.size.height);
    CGFloat endRectDepth = isEdgeVertical(edge) ? marginedDestRect.size.height : marginedDestRect.size.width;
    TFYSegment aPoints = bezierEndPointsForTransition(edge, [self convertRect:CGRectInset(self.bounds, xInset, yInset) toView:self.superview]);
    
    TFYSegment bEndPoints = bezierEndPointsForTransition(edge, marginedDestRect);
    TFYSegment bStartPoints = aPoints;
    bStartPoints.a.v[axis] = bEndPoints.a.v[axis];
    bStartPoints.b.v[axis] = bEndPoints.b.v[axis];
    
    TFYBezierCurve first = {aPoints.a, bStartPoints.a};
    TFYBezierCurve second = {aPoints.b, bStartPoints.b};
    
    // View hierarchy setup
    
    NSString *sumKeyPath = isEdgeVertical(edge) ? @"@sum.bounds.size.height" : @"@sum.bounds.size.width";
    CGFloat totalSize = [[slices valueForKeyPath:sumKeyPath] floatValue];
    
    CGFloat sign = isEdgeNegative(edge) ? -1.0 : 1.0;

    if (sign*(aPoints.a.v[axis] - bEndPoints.a.v[axis]) > 0.0f) {


        NSLog(@"Genie Effect ERROR: The distance between %@ edge of animated view and %@ edge of %@ rect is incorrect. Animation will not be performed!", edgeDescription(edge), edgeDescription(edge), reverse ? @"star" : @"destination");
        return;
    } else if (sign*(aPoints.a.v[axis] + sign*totalSize - bEndPoints.a.v[axis]) > 0.0f) {
        NSLog(@"Genie Effect Warning: The %@ edge of animated view overlaps %@ edge of %@ rect. Glitches may occur.",edgeDescription((edge + 2) % 4), edgeDescription(edge), reverse ? @"start" : @"destination");
    }
    
    UIView *containerView = [[UIView alloc] initWithFrame:[self.superview bounds]];
    containerView.clipsToBounds = self.superview.clipsToBounds; // if superview does it then we should probably do it as well
    containerView.backgroundColor = [UIColor clearColor];    
    [self.superview insertSubview:containerView belowSubview:self];
    
    NSMutableArray *transforms = [NSMutableArray arrayWithCapacity:[slices count]];
    
    for (CALayer *layer in slices) {
        [containerView.layer addSublayer:layer];
        [transforms addObject:[NSMutableArray array]];
    }
    
    BOOL previousHiddenState = self.hidden;
    self.hidden = YES; // hide self throught animation, slices will be shown instead
    
    // Animation frames

    NSInteger totalIter = duration*kFPS;
    double tSignShift = reverse ? -1.0 : 1.0;
    
    for (int i = 0; i < totalIter; i++) {
        
        double progress = ((double)i)/((double)totalIter - 1.0);        
        double t = tSignShift*(progress - 0.5) + 0.5;
        
        double curveP = progressOfSegmentWithinTotalProgress(curvesAnimationStart, curvesAnimationEnd, t);
        
        first.b.v[pAxis] = easeInOutInterpolate(curveP, bStartPoints.a.v[pAxis], bEndPoints.a.v[pAxis]);
        second.b.v[pAxis] = easeInOutInterpolate(curveP, bStartPoints.b.v[pAxis], bEndPoints.b.v[pAxis]);
        
        double slideP = progressOfSegmentWithinTotalProgress(slideAnimationStart, slideAnimationEnd, t);
        
        NSArray *trs = [self transformationsForSlices:slices edge:edge startPosition:easeInOutInterpolate(slideP, first.a.v[axis], first.b.v[axis]) totalSize:totalSize firstBezier:first secondBezier:second finalRectDepth:endRectDepth];
        
        [trs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [transforms[idx] addObject:obj];
        }];
    }
    
    // Animation firing
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
    
        [containerView removeFromSuperview];
    
        CGSize startSize = self.frame.size;
        CGSize endSize = destRect.size;
    
        CGPoint startOrigin = self.frame.origin;
        CGPoint endOrigin = destRect.origin;
        
        if (! reverse) {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(endOrigin.x - startOrigin.x, endOrigin.y - startOrigin.y); // move to destination
            transform = CGAffineTransformTranslate(transform, -startSize.width/2.0, -startSize.height/2.0); // move top left corner to origin
            transform = CGAffineTransformScale(transform, endSize.width/startSize.width, endSize.height/startSize.height); // scale
            transform = CGAffineTransformTranslate(transform, startSize.width/2.0, startSize.height/2.0); // move back
            
            self.transform = transform;
        }

        self.hidden = previousHiddenState;
        
        if (completion) {
            completion();
        }
    }];
    
    [slices enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        anim.duration = duration;
        anim.values = transforms[idx];
        anim.calculationMode = kCAAnimationDiscrete;
        anim.removedOnCompletion = NO;
        anim.fillMode = kCAFillModeForwards;
        [layer addAnimation:anim forKey:@"transform"];
    }];
    
    [CATransaction commit];
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

- (UIImage *)renderSnapshotWithMarginForAxis:(TFYAxis)axis
{
    CGSize contextSize = self.frame.size;
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 0.0f;
    
    if (axis == TFYAxisY) {
        xOffset = kRenderMargin;
        contextSize.width += 2.0*kRenderMargin;
    } else {
        yOffset = kRenderMargin;
        contextSize.height += 2.0*kRenderMargin;
    }
    
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0.0); // if you want to see border added for antialiasing pass YES as second param
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, xOffset, yOffset);
    
    [self.layer renderInContext:context];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


- (NSArray *)sliceImage:(UIImage *)image toLayersAlongAxis:(TFYAxis) axis
{
    CGFloat totalSize = axis == TFYAxisY ? image.size.height : image.size.width;
    
    TFYPoint origin = {0.0, 0.0};
    origin.v[axis] = kSliceSize;
    
    CGFloat scale = image.scale;
    CGSize sliceSize = axis == TFYAxisY ? CGSizeMake(image.size.width, kSliceSize) : CGSizeMake(kSliceSize, image.size.height);
    
    NSInteger count = (NSInteger)ceilf(totalSize/kSliceSize);
    NSMutableArray *slices = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        CGRect rect = {i*origin.x*scale, i*origin.y*scale, sliceSize.width*scale, sliceSize.height*scale};
        UIImage *sliceImage = [UIImage imageWithCGImage: CGImageCreateWithImageInRect(image.CGImage, rect) scale:image.scale orientation:image.imageOrientation];
        
        CALayer *layer = [CALayer layer];
        layer.anchorPoint = CGPointZero;
        layer.bounds = CGRectMake(0.0, 0.0, sliceImage.size.width, sliceImage.size.height);
        layer.contents = (__bridge id)(sliceImage.CGImage);
        layer.contentsScale = image.scale;
        [slices addObject:layer];
    }
    
    return slices;
}


- (NSArray *)transformationsForSlices:(NSArray *)slices edge:(TFYRectEdge)edge startPosition:(CGFloat)startPosition totalSize:(CGFloat)totalSize firstBezier:(TFYBezierCurve)first secondBezier:(TFYBezierCurve)second finalRectDepth:(CGFloat)rectDepth
{
    NSMutableArray *transformations = [NSMutableArray arrayWithCapacity:[slices count]];
    
    TFYAxis axis = axisForEdge(edge);
    
    CGFloat rectPartStart = first.b.v[axis];
    CGFloat sign = isEdgeNegative(edge) ? -1.0 : 1.0;

    assert(sign*(startPosition - rectPartStart) <= 0.0);
    
    __block CGFloat position = startPosition;
    __block TFYTrapezoid trapezoid = {0};
    trapezoid.v[TFYTrapezoidWinding[edge][0]] = bezierAxisIntersection(first, axis, position);
    trapezoid.v[TFYTrapezoidWinding[edge][1]] = bezierAxisIntersection(second, axis, position);
    
    NSEnumerationOptions enumerationOptions = isEdgeNegative(edge) ? NSEnumerationReverse : 0;
    
    [slices enumerateObjectsWithOptions:enumerationOptions usingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CGFloat size = isEdgeVertical(edge) ? layer.bounds.size.height : layer.bounds.size.width;
        CGFloat endPosition = position + sign*size; // we're not interested in slices' origins since they will be moved around anyway
        
        double overflow = sign*(endPosition - rectPartStart);
        
        if (overflow <= 0.0f) { // slice is still in bezier part
            trapezoid.v[TFYTrapezoidWinding[edge][2]] = bezierAxisIntersection(first, axis, endPosition);
            trapezoid.v[TFYTrapezoidWinding[edge][3]] = bezierAxisIntersection(second, axis, endPosition);
        }
        else { // final rect part
            CGFloat shrunkSliceDepth = overflow*rectDepth/(double)totalSize; // how deep inside final rect "bottom" part of slice is
            
            trapezoid.v[TFYTrapezoidWinding[edge][2]] = first.b;
            trapezoid.v[TFYTrapezoidWinding[edge][2]].v[axis] += sign*shrunkSliceDepth;
            
            trapezoid.v[TFYTrapezoidWinding[edge][3]] = second.b;
            trapezoid.v[TFYTrapezoidWinding[edge][3]].v[axis] += sign*shrunkSliceDepth;
        }
        
        CATransform3D transform = [self transformRect:layer.bounds toTrapezoid:trapezoid];
        [transformations addObject:[NSValue valueWithCATransform3D:transform]];
        
        trapezoid.v[TFYTrapezoidWinding[edge][0]] = trapezoid.v[TFYTrapezoidWinding[edge][2]]; // next one starts where previous one ends
        trapezoid.v[TFYTrapezoidWinding[edge][1]] = trapezoid.v[TFYTrapezoidWinding[edge][3]];
        
        position = endPosition;
    }];
    
    if (isEdgeNegative(edge)) {
        return [[transformations reverseObjectEnumerator] allObjects];
    }
    
    return transformations;
}

- (CATransform3D)transformRect:(CGRect) rect toTrapezoid:(TFYTrapezoid)trapezoid
{

    double W = rect.size.width;
    double H = rect.size.height;
    
    double x1a = trapezoid.a.x;
    double y1a = trapezoid.a.y;
    
    double x2a = trapezoid.b.x;
    double y2a = trapezoid.b.y;
    
    double x3a = trapezoid.c.x;
    double y3a = trapezoid.c.y;
    
    double x4a = trapezoid.d.x;
    double y4a = trapezoid.d.y;
    
    double y21 = y2a - y1a,
    y32 = y3a - y2a,
    y43 = y4a - y3a,
    y14 = y1a - y4a,
    y31 = y3a - y1a,
    y42 = y4a - y2a;
    
    
    double a = -H*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42);
    double b = W*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    double c = - H*W*x1a*(x4a*y32 - x3a*y42 + x2a*y43);
    
    double d = H*(-x4a*y21*y3a + x2a*y1a*y43 - x1a*y2a*y43 - x3a*y1a*y4a + x3a*y2a*y4a);
    double e = W*(x4a*y2a*y31 - x3a*y1a*y42 - x2a*y31*y4a + x1a*y3a*y42);
    double f = -(W*(x4a*(H*y1a*y32) - x3a*(H)*y1a*y42 + H*x2a*y1a*y43));
    
    double g = H*(x3a*y21 - x4a*y21 + (-x1a + x2a)*y43);
    double h = W*(-x2a*y31 + x4a*y31 + (x1a - x3a)*y42);
    double i = H*(W*(-(x3a*y2a) + x4a*y2a + x2a*y3a - x4a*y3a - x2a*y4a + x3a*y4a));
    
    const double kEpsilon = 0.0001;
    
    if(fabs(i) < kEpsilon) {
        i = kEpsilon* (i > 0 ? 1.0 : -1.0);
    }
    
    CATransform3D transform = {a/i, d/i, 0, g/i, b/i, e/i, 0, h/i, 0, 0, 1, 0, c/i, f/i, 0, 1.0};
    
    return transform;
}


#pragma mark - C convinience functions

static TFYSegment bezierEndPointsForTransition(TFYRectEdge edge, CGRect endRect)
{
    switch (edge) {
        case TFYRectEdgeTop:
            return TFYSegmentMake(TFYPointMake(CGRectGetMinX(endRect), CGRectGetMinY(endRect)), TFYPointMake(CGRectGetMaxX(endRect), CGRectGetMinY(endRect)));
        case TFYRectEdgeBottom:
            return TFYSegmentMake(TFYPointMake(CGRectGetMaxX(endRect), CGRectGetMaxY(endRect)), TFYPointMake(CGRectGetMinX(endRect), CGRectGetMaxY(endRect)));
        case TFYRectEdgeRight:
            return TFYSegmentMake(TFYPointMake(CGRectGetMaxX(endRect), CGRectGetMinY(endRect)), TFYPointMake(CGRectGetMaxX(endRect), CGRectGetMaxY(endRect)));
        case TFYRectEdgeLeft:
            return TFYSegmentMake(TFYPointMake(CGRectGetMinX(endRect), CGRectGetMaxY(endRect)), TFYPointMake(CGRectGetMinX(endRect), CGRectGetMinY(endRect)));
    }
    
    assert(0); // should never happen
}

static inline CGFloat progressOfSegmentWithinTotalProgress(CGFloat a, CGFloat b, CGFloat t)
{
    assert(b > a);
    
    return MIN(MAX(0.0, (t - a)/(b - a)), 1.0);
}

static inline CGFloat easeInOutInterpolate(float t, CGFloat a, CGFloat b)
{
    assert(t >= 0.0 && t <= 1.0); // we don't want any other values
    
    CGFloat val = a + t*t*(3.0 - 2.0*t)*(b - a);
    
    return b > a ? MAX(a,  MIN(val, b)) : MAX(b,  MIN(val, a)); // clamping, since numeric precision might bite here
}

static TFYPoint bezierAxisIntersection(TFYBezierCurve curve, TFYAxis axis, CGFloat axisPos)
{
    assert((axisPos >= curve.a.v[axis] && axisPos <= curve.b.v[axis]) || (axisPos >= curve.b.v[axis] && axisPos <= curve.a.v[axis]));
    
    TFYAxis pAxis = perpAxis(axis);
    
    TFYPoint c1, c2;
    c1.v[pAxis] = curve.a.v[pAxis];
    c1.v[axis] = (curve.a.v[axis] + curve.b.v[axis])/2.0;
    
    c2.v[pAxis] = curve.b.v[pAxis];
    c2.v[axis] = (curve.a.v[axis] + curve.b.v[axis])/2.0;
    
    double t = (axisPos - curve.a.v[axis])/(curve.b.v[axis] - curve.a.v[axis]); // first approximation - treating curve as linear segment
    
    const int kIterations = 3; // Newton-Raphson iterations
    
    for (int i = 0; i < kIterations; i++) {
        double nt = 1.0 - t;
        
        double f = nt*nt*nt*curve.a.v[axis] + 3.0*nt*nt*t*c1.v[axis] + 3.0*nt*t*t*c2.v[axis] + t*t*t*curve.b.v[axis] - axisPos;
        double df = -3.0*(curve.a.v[axis]*nt*nt + c1.v[axis]*(-3.0*t*t + 4.0*t - 1.0) + t*(3.0*c2.v[axis]*t - 2.0*c2.v[axis] - curve.b.v[axis]*t));
        
        t -= f/df;
    }
    
    assert(t >= 0 && t <= 1.0);
    
    double nt = 1.0 - t;
    double intersection = nt*nt*nt*curve.a.v[pAxis] + 3.0*nt*nt*t*c1.v[pAxis] + 3.0*nt*t*t*c2.v[pAxis] + t*t*t*curve.b.v[pAxis];
    
    TFYPoint ret;
    ret.v[axis] = axisPos;
    ret.v[pAxis] = intersection;
    
    return ret;
}

static inline NSString * edgeDescription(TFYRectEdge edge)
{
    NSString *rectEdge[] = {
        [TFYRectEdgeBottom] = @"bottom",
        [TFYRectEdgeTop] = @"top",
        [TFYRectEdgeRight] = @"right",
        [TFYRectEdgeLeft] = @"left",
    };
    
    return rectEdge[edge];
}

- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *)color {
    
    [self.layer tfy_cornerRadius:radius cornerColor:color];
}

- (void)tfy_cornerRadius:(CGFloat)radius cornerColor:(UIColor *)color corners:(UIRectCorner)corners {
    
    [self.layer tfy_cornerRadius:radius cornerColor:color corners:corners];
}

- (void)tfy_cornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *)color corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    
    [self.layer tfy_cornerRadii:cornerRadii cornerColor:color corners:corners borderColor:borderColor borderWidth:borderWidth];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

+ (UIView *)tfy_gradientViewWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UIView *view = [[self alloc] init];
    [view tfy_setGradientBackgroundWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    return view;
}

- (void)tfy_setGradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *color in colors) {
        [colorsM addObject:(__bridge id)color.CGColor];
    }
    self.tfy_colors = [colorsM copy];
    self.tfy_locations = locations;
    self.tfy_startPoint = startPoint;
    self.tfy_endPoint = endPoint;
}

#pragma mark- Getter&Setter

- (NSArray *)tfy_colors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTfy_colors:(NSArray *)colors {
    objc_setAssociatedObject(self, @selector(tfy_colors), colors, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setColors:self.tfy_colors];
    }
}

- (NSArray<NSNumber *> *)tfy_locations {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTfy_locations:(NSArray<NSNumber *> *)locations {
    objc_setAssociatedObject(self, @selector(tfy_locations), locations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setLocations:self.tfy_locations];
    }
}

- (CGPoint)tfy_startPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setTfy_startPoint:(CGPoint)startPoint {
    objc_setAssociatedObject(self, @selector(tfy_startPoint), [NSValue valueWithCGPoint:startPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setStartPoint:self.tfy_startPoint];
    }
}

- (CGPoint)tfy_endPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setTfy_endPoint:(CGPoint)endPoint {
    objc_setAssociatedObject(self, @selector(tfy_endPoint), [NSValue valueWithCGPoint:endPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setEndPoint:self.tfy_endPoint];
    }
}


/**
 * 添加四边阴影效果
 */
- (void)tfy_addShadowToView:(UIView *_Nonnull)theView withColor:(UIColor *_Nonnull)theColor{
    // 阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    // 阴影偏移，默认(0, -3)
    theView.layer.shadowOffset = CGSizeMake(0,0);
    // 阴影透明度，默认0
    theView.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    theView.layer.shadowRadius = 5;
}


/**
 *  添加单边阴影效果
 */
-(void)tfy_addShadowhalfView:(UIView *_Nonnull)theView withColor:(UIColor *_Nonnull)theColor{
    theView.layer.shadowColor = theColor.CGColor;
    theView.layer.shadowOffset = CGSizeMake(0,0);
    theView.layer.shadowOpacity = 0.5;
    theView.layer.shadowRadius = 5;
    // 单边阴影 顶边
    float shadowPathWidth = theView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, theView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    theView.layer.shadowPath = path.CGPath;
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

-(void)tfy_setShadow:(CGSize)size shadowOpacity:(CGFloat)opacity shadowRadius:(CGFloat)radius shadowColor:(UIColor *_Nonnull)color{
    self.layer.shadowOffset = size;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowColor = color.CGColor;
}
@end

@implementation UILabel (TFY_Gradient)

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end
