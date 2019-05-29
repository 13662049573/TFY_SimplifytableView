//
//  TFY_CellData.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CellRegisterType) {
    CellRegisterTypeClass = 0,
    CellRegisterTypeXib = 1,
};
/**
 *  行数 高度 返回block
 */
typedef CGFloat (^RowHeightBlock)(NSIndexPath * _Nonnull indexPath);
/**
 *  赋值 cell 数据 行数 返回所需的Block
 */
typedef void (^CellAdapterBlock)(__kindof UITableViewCell *cell, id data, NSIndexPath * _Nonnull indexPath);
/**
 *  点击方法 tableview 行数 数据 x所需block
 */
typedef void (^CellEventBlock)(UITableView *tableView, NSIndexPath * _Nonnull indexPath, id data);

@interface TFY_CellData : NSObject
/**
 *  初始一个tableview
 */
@property(nonatomic , weak)UITableView *tableView;
/**
 *  数据
 */
@property(nonatomic , assign)id data;
/**
 *  高度Block
 */
@property(nonatomic , copy)RowHeightBlock rowHeightBlock;
/**
 *  赋值高度
 */
@property(nonatomic , assign)CGFloat rowHeight;
/**
 *  cell类型
 */
@property(nonatomic , assign)CellRegisterType cellRegisterType;
/**
 *  cell Class 类
 */
@property(nonatomic , strong)Class cell;
/**
 *  独立的赋值参数
 */
@property(nonatomic , copy)NSString *cellidentifier;
/**
 *  赋值的cell block
 */
@property(nonatomic , copy)CellAdapterBlock adapter;
/**
 *  点击方法 cell block
 */
@property(nonatomic , copy)CellEventBlock event;
/**
 *  行数
 */
@property(nonatomic , strong)NSIndexPath *indexPath;
/**
 *  是否自适应高度
 */
@property(nonatomic , assign)BOOL isAutoHeight;
/**
 *  返回cell
 */
-(UITableViewCell *)getReturnCell;

@end

@interface TFY_CellMaker : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;
/**
 *
 */
@property (nonatomic, strong) TFY_CellData *cellData;
/**
 *
 */
- (NSIndexPath *)indexPath;
/**
 *
 */
- (TFY_CellMaker * (^)(CGFloat))tfy_rowHeight;
/**
 *
 */
- (TFY_CellMaker * (^)(void))tfy_autoHeight;
/**
 *
 */
- (TFY_CellMaker * (^)(Class))tfy_cellClass;
/**
 *
 */
- (TFY_CellMaker * (^)(Class))tfy_cellClassXib;
/**
 *
 */
- (TFY_CellMaker * (^)(id))tfy_data;
/**
 *
 */
- (TFY_CellMaker * (^)(CellAdapterBlock))tfy_adapter;
/**
 *
 */
- (TFY_CellMaker * (^)(CellEventBlock))tfy_event;
/**
 *
 */
- (TFY_CellMaker * (^)(Class,CellAdapterBlock))tfy_cellClassAndAdapter;


@end


NS_ASSUME_NONNULL_END
