//
//  TFY_BaseTableViewDataSource.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

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
 *  cell 模型
 */
@property (nonatomic, strong) TFY_CellData *cellData;
/**
 *  获取行数
 */
- (NSIndexPath *)indexPath;
/**
 *  cell 的高度
 */
- (TFY_CellMaker * (^)(CGFloat))tfy_rowHeight;
/**
 *   自动获取高度布局
 */
- (TFY_CellMaker * (^)(void))tfy_autoHeight;
/**
 *  cell 类返回对象block [UItabaleViewCell Class];
 */
- (TFY_CellMaker * (^)(Class))tfy_cellClass;
/**
 *   xib  cell 类返回对象block
 */
- (TFY_CellMaker * (^)(Class))tfy_cellClassXib;
/**
 *   cell data 数据赋值
 */
- (TFY_CellMaker * (^)(id))tfy_data;
/**
 *  cell 同tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 这个方法
 */
- (TFY_CellMaker * (^)(CellAdapterBlock))tfy_adapter;
/**
 *  cell 同 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 */
- (TFY_CellMaker * (^)(CellEventBlock))tfy_event;
/**
 *  cell 同tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 这个方法
 */
- (TFY_CellMaker * (^)(Class,CellAdapterBlock))tfy_cellClassAndAdapter;


@end

/**
 *   数据赋值block
 */
typedef  NSArray * _Nonnull (^GetDataBlock)(void);
/**
 *   组数赋值 block
 */
typedef  NSInteger (^NumberOfRowsBlock)(NSInteger section);
/**
 *   模型block方法
 */
typedef void (^CellMakeBlock)(TFY_CellMaker * _Nonnull cellMaker);

@interface TFY_SectionData : NSObject
/**
 *  是否自定义cell
 */
@property(nonatomic, assign) BOOL isStaticCell;
/**
 *  模型数据
 */
@property(nonatomic, strong) NSMutableArray<TFY_CellData *> * cellDatas;
/**
 * tableView
 */
@property(nonatomic, weak) UITableView * tableView;
/**
 *  模型数据数组
 */
@property (nonatomic, strong) NSArray *modelDatas;
/**
 *  header 头文件字符串
 */
@property(nonatomic, strong) NSString * headerTitle;
/**
 *  footer 头文件字符串
 */
@property(nonatomic, strong) NSString * footerTitle;
/**
 *  header 高度
 */
@property (nonatomic, assign) CGFloat headerHeight;
/**
 *  footer 高度
 */
@property (nonatomic, assign) CGFloat footerHeight;
/**
 *   头部 headerView
 */
@property(nonatomic, strong) UIView * headerView;
/**
 *  尾部 ：footerView
 */
@property(nonatomic, strong) UIView * footerView;
/**
 *  cell 高度
 */
@property(nonatomic, assign) CGFloat rowHeight;
/**
 *  组行
 */
@property (nonatomic, assign) NSUInteger section;
/**
 *  组个数
 */
@property (nonatomic, assign) NSUInteger rowCount;
/**
 *  行个数
 */
@property(nonatomic, copy) NumberOfRowsBlock numberOfRowsBlock;
/**
 *  cell  模型 block
 */
@property(nonatomic, copy) CellMakeBlock cellMakeBlock;
/**
 *  cell 数组 Block
 */
@property(nonatomic, copy) GetDataBlock getDataBlock;
/**
 *
 */
- (void)doCellMakerBlock;
/**
 *
 */
- (void)doAddCellMakerBlock:(CellMakeBlock)cellMakerBlock;

@end

@interface TFY_SectionMaker : NSObject
/**
 *
 */
- (instancetype)initWithTableView:(UITableView *)tableView;
/**
 *
 */
- (TFY_SectionMaker * (^)(GetDataBlock))tfy_dataArr;
/**
 *
 */
- (NSUInteger)section;
/**
 *
 */
- (TFY_SectionMaker * (^)(NSString *))tfy_headerTitle;
/**
 *
 */
- (TFY_SectionMaker * (^)(NSString *))tfy_footerTitle;
/**
 *
 */
- (TFY_SectionMaker * (^)(UIView * (^)(void)))tfy_headerView;
/**
 *
 */
- (TFY_SectionMaker * (^)(UIView * (^)(void)))tfy_footerView;
/**
 *
 */
- (TFY_SectionMaker * (^)(CGFloat)) tfy_rowHeight;
/**
 *
 */
- (TFY_SectionMaker * (^)(CGFloat)) tfy_headerHeight;
/**
 *
 */
- (TFY_SectionMaker * (^)(CGFloat)) tfy_footerHeight;
/**
 *
 */
- (TFY_SectionMaker * (^)(NSInteger))tfy_rowCount;
/**
 *
 */
- (TFY_SectionMaker * (^)(CellMakeBlock))tfy_cellMaker;
/**
 *
 */
- (TFY_SectionMaker * (^)(CellMakeBlock))tfy_addCellMaker;
/**
 *
 */
- (TFY_SectionMaker *)tfy_cellMaker:(CellMakeBlock)cellMakerBlock;
/**
 *
 */
- (TFY_SectionMaker *)tfy_addCellMaker:(CellMakeBlock)cellMakerBlock;
/**
 *
 */
@property(nonatomic, strong) TFY_SectionData * sectionData;

@end

/**
 *
 */
typedef void (^CellWillDisplayBlock)(UITableView *tableView,UITableViewCell *willDisplayCell,NSIndexPath *indexPath);
/**
 *
 */
typedef void (^CommitEditingBlock)(UITableView * tableView,UITableViewCellEditingStyle editingStyle,NSIndexPath * indexPath);
/**
 *
 */
typedef void (^ScrollViewDidScrollBlock)(UIScrollView *scrollView);
/**
 *
 */
typedef void (^SectionMakeBlock)(TFY_SectionMaker * sectionMaker);
/**
 *
 */
typedef NSUInteger (^SectionCountBlock)(UITableView *tableView);

@interface TFY_TableData : NSObject
/**
 *
 */
-(instancetype) initWithTableView:(UITableView *)tableView;
/**
 *
 */
- (void)doAddSectionMaker:(SectionMakeBlock)sectionMakerBlock;
/**
 *
 */
- (void)doSectionMakeBlock;
/**
 *
 */
@property(nonatomic, weak) UITableView * tableView;
/**
 *
 */
@property(nonatomic, strong) NSMutableArray<TFY_SectionData *> * sectionDatas;
/**
 *
 */
@property (nonatomic, assign) NSUInteger sectionCount;
/**
 *
 */
@property (nonatomic, strong) NSArray *dataArr;
/**
 *
 */
@property (nonatomic, assign) CGFloat rowHeight;
/**
 *
 */
@property (nonatomic, copy)  SectionMakeBlock sectionMakeBlock;
/**
 *
 */
@property (nonatomic, copy)  SectionCountBlock sectionCountBlock;
/**
 *
 */
@property(nonatomic, strong) NSMutableDictionary * otherDelegateBlocksDic;

@end

@interface TFY_TableViewMaker : NSObject
/**
 *
 */
@property (nonatomic, strong)TFY_TableData *tableData;
/**
 *
 */
- (instancetype)initWithTableView:(UITableView *)tableView;
/**
 *
 */
- (instancetype)initWithTableData:(TFY_TableData *)tableData;
/**
 *
 */
- (TFY_TableViewMaker * (^)(CGFloat))tfy_height;
/**
 *
 */
- (TFY_TableViewMaker * (^)(UIView * (^)(void)))tfy_tableViewHeaderView;
/**
 *
 */
- (TFY_TableViewMaker * (^)(UIView * (^)(void)))tfy_tableViewFooterView;
/**
 *
 */
- (TFY_TableViewMaker * (^)(NSInteger))tfy_sectionCount;
/**
 *
 */
- (TFY_TableViewMaker * (^)(SectionCountBlock))tfy_sectionCountBk;
/**
 *
 */
- (TFY_TableViewMaker * (^)(SectionMakeBlock))tfy_sectionMaker;
/**
 *
 */
- (TFY_TableViewMaker *) tfy_sectionMaker:(SectionMakeBlock)sectionMakeBlock;
/**
 *
 */
- (TFY_TableViewMaker * (^)(SectionMakeBlock))tfy_addSectionMaker;
/**
 *
 */
- (TFY_TableViewMaker *) tfy_addSectionMaker:(SectionMakeBlock)sectionMakeBlock;
/**
 *
 */
- (TFY_TableViewMaker * (^)(CellWillDisplayBlock))tfy_cellWillDisplay;
/**
 *
 */
- (TFY_TableViewMaker * (^)(CommitEditingBlock))tfy_commitEditing;
/**
 *
 */
- (TFY_TableViewMaker * (^)(ScrollViewDidScrollBlock))tfy_scrollViewDidScroll;


@end

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
