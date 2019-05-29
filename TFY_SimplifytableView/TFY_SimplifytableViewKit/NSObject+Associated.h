//
//  NSObject+Associated.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Associated)
- (nullable id)tfy_getAssociatedObjectWithKey:(const void *)cKey;

- (void)tfy_setAssociatedAssignObject:(nullable id)cValue key:(const void *)cKey;

- (void)tfy_setAssociatedRetainObject:(nullable id)cValue key:(const void *)cKey;

- (void)tfy_setAssociatedCopyObject:(nullable id)cValue key:(const void *)cKey;

- (void)tfy_setAssociatedObject:(nullable id)cValue key:(const void *)cKey policy:(objc_AssociationPolicy)cPolicy;
@end

NS_ASSUME_NONNULL_END
