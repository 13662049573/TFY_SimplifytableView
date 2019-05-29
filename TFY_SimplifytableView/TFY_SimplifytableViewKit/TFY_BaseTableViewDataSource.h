//
//  TFY_BaseTableViewDataSource.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

#import "TFY_TableData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_BaseTableViewDataSourceProtocol<UITableViewDataSource,UITableViewDelegate>
/**
 *
 */
@property (nonatomic, strong)TFY_TableData *tableData;

@end

@interface TFY_BaseTableViewDataSource : NSObject<TFY_BaseTableViewDataSourceProtocol>
/**
 *
 */
@property (nonatomic, strong)TFY_TableData *tableData;
@end

NS_ASSUME_NONNULL_END
