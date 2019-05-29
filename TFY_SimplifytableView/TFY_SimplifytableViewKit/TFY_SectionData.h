//
//  TFY_SectionData.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TFY_CellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *
 */
typedef  NSArray * _Nonnull (^GetDataBlock)(void);
/**
 *
 */
typedef  NSInteger (^NumberOfRowsBlock)(NSInteger section);
/**
 *
 */
typedef void (^CellMakeBlock)(TFY_CellMaker * _Nonnull cellMaker);

@interface TFY_SectionData : NSObject
/**
 *
 */
@property(nonatomic, assign) BOOL isStaticCell;
/**
 *
 */
@property(nonatomic, strong) NSMutableArray<TFY_CellData *> * cellDatas;
/**
 *
 */
@property(nonatomic, weak) UITableView * tableView;
/**
 *
 */
@property (nonatomic, strong) NSArray *modelDatas;
/**
 *
 */
@property(nonatomic, strong) NSString * headerTitle;
/**
 *
 */
@property(nonatomic, strong) NSString * footerTitle;
/**
 *
 */
@property (nonatomic, assign) CGFloat headerHeight;
/**
 *
 */
@property (nonatomic, assign) CGFloat footerHeight;
/**
 *
 */
@property(nonatomic, strong) UIView * headerView;
/**
 *
 */
@property(nonatomic, strong) UIView * footerView;
/**
 *
 */
@property(nonatomic, assign) CGFloat rowHeight;
/**
 *
 */
@property (nonatomic, assign) NSUInteger section;
/**
 *
 */
@property (nonatomic, assign) NSUInteger rowCount;
/**
 *
 */
@property(nonatomic, copy) NumberOfRowsBlock numberOfRowsBlock;
/**
 *
 */
@property(nonatomic, copy) CellMakeBlock cellMakeBlock;
/**
 *
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


NS_ASSUME_NONNULL_END
