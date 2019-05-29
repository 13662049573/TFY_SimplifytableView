//
//  ViewModel.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ViewModel.h"

@implementation RACCommandData

-(RACCommand *)viewModelCommand{
    if (!_viewModelCommand) {
        _viewModelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                NSDictionary *dict = [NSDictionary tfy_NSDictionpathForResource:@"ViewData" ofType:@"json"];
                
                ViewModel *model = [ViewModel tfy_ModelWithJson:dict];
                
                [subscriber sendNext:model];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _viewModelCommand;
}


@end

@implementation Model_detail

@end
@implementation Prod_list
+(NSDictionary <NSString *, Class> *)tfy_ModelReplacePropertyClassMapper{
    return @{@"model_detail":[Model_detail class]};
}
@end
@implementation Data
+(NSDictionary <NSString *, Class> *)tfy_ModelReplacePropertyClassMapper{
    return @{@"prod_list":[Prod_list class]};
}
@end
@implementation ViewModel
+(NSDictionary <NSString *, Class> *)tfy_ModelReplacePropertyClassMapper{
    return @{@"data":[Data class]};
}
@end
