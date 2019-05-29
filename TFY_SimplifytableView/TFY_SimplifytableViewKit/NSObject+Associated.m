//
//  NSObject+Associated.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "NSObject+Associated.h"

@implementation NSObject (Associated)

- (id)tfy_getAssociatedObjectWithKey:(const void *)cKey
{
    return objc_getAssociatedObject(self, cKey);
}

- (void)tfy_setAssociatedAssignObject:(id)cValue key:(const void *)cKey
{
    objc_setAssociatedObject(self, cKey, cValue, OBJC_ASSOCIATION_ASSIGN);
}

- (void)tfy_setAssociatedRetainObject:(id)cValue key:(const void *)cKey
{
    objc_setAssociatedObject(self, cKey, cValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)tfy_setAssociatedCopyObject:(id)cValue key:(const void *)cKey
{
    objc_setAssociatedObject(self, cKey, cValue, OBJC_ASSOCIATION_COPY);
}

- (void)tfy_setAssociatedObject:(id)cValue key:(const void *)cKey policy:(objc_AssociationPolicy)cPolicy
{
    objc_setAssociatedObject(self, cKey, cValue, cPolicy);
}

@end
