//
//  TFY_TableData.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TFY_SectionData,TFY_SectionMaker;

NS_ASSUME_NONNULL_BEGIN
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


NS_ASSUME_NONNULL_END
