//
//  NSObject+TFY_Model.h
//  TFY_CHESHI
//
//  Created by 田风有 on 2019/4/25.
//  Copyright © 2019 田风有. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <Foundation/Foundation.h>
/**
 *  模型对象归档解归档实现
 */
#define TFY_CodingImplementation \
-(id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]){ \
[self tfy_Decode:decoder]; \
} \
return self; \
} \
\
-(void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self tfy_Encode:encoder]; \
}\
-(id)copyWithZone:(NSZone *)zone{return [self tfy_Copy];}


NS_ASSUME_NONNULL_BEGIN

@protocol TFY_ModelKeyValue <NSObject>
@optional
/**
 *  模型类l可以定义属性名称<json key名，替换实际属性>
 */
+(NSDictionary <NSString *,NSString *> *)tfy_ModelReplacePropertyMapper;
/**
 *  模型数组/字典元素对象可自定义类<替换实际属性名，实际类>
 */
+(NSDictionary <NSString *, Class> *)tfy_ModelReplaceContainerElementClassMapper;
/**
 *  模型可自定义属性类型<替换实际属性名，实际类>
 */
+(NSDictionary <NSString *, Class> *)tfy_ModelReplacePropertyClassMapper;

@end

@interface NSObject (TFY_Model) <TFY_ModelKeyValue>

#pragma mark-json转模型对象 Api
/**
 *  字典转模型数据
 */
+(id)tfy_ModelWithJson:(id)json;
/**
 *  字典解析模型，keypath选择对象层次来解析数据
 */
+(id)tfy_ModelWithJson:(id)json keyPath:(NSString *)keyPath;

#pragma mark - 模型对象序列化 Api
/**
 *  将模型转为字典
 */
-(NSDictionary *)tfy_Dictionary;
/**
 *  把模型字典转化为字符串
 */
-(NSString *)tfy_Json;

#pragma mark - 模型对象序列化
/**
 *  复制模型对象
 */
-(id)tfy_Copy;
/**
 *  序列化模型对象
 */
-(void)tfy_Encode:(NSCoder *)aCoder;
/**
 *  反序列化模型对象
 */
-(void)tfy_Decode:(NSCoder *)aDecoder;

@end

NS_ASSUME_NONNULL_END
