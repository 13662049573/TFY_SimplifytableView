//
//  ViewModel.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RACCommandData : NSObject

@property(nonatomic , strong)RACCommand *viewModelCommand;

@end


@interface Model_detail : NSObject
@property (nonatomic , copy) NSString     *text_key;
@property (nonatomic , copy) NSString     *value;
@property (nonatomic , copy) NSString     *img;
@property (nonatomic , copy) NSString     *type_name;

@end

@interface Prod_list : NSObject
@property (nonatomic , copy) NSString     *title;
@property (nonatomic , copy) NSArray<Model_detail *>     *model_detail;

@end

@interface Data : NSObject
@property (nonatomic , copy) NSString     *nick_name;
@property (nonatomic , copy) NSArray<Prod_list *>     *prod_list;
@property (nonatomic , copy) NSString     *user_avatar;

@end

@interface ViewModel : NSObject
@property (nonatomic , copy) NSArray<Data *>     *data;

@end

NS_ASSUME_NONNULL_END
