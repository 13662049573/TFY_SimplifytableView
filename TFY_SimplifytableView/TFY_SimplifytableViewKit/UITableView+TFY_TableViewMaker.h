//
//  UITableView+TFY_TableViewMaker.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_BaseTableViewDataSource,TFY_TableViewMaker;

NS_ASSUME_NONNULL_BEGIN


@interface UITableView (TFY_TableViewMaker)
/**
 *
 */
@property(nonatomic, strong)TFY_BaseTableViewDataSource * tfy_TableViewDataSource;
/**
 *
 */
@property (nonatomic,strong) NSMutableDictionary *tableViewRegisterCell;
/**
 *
 */
- (UITableView *)tfy_tableViewMaker:(void (^)(TFY_TableViewMaker * tableMaker))tableViewMaker;

@end
/**
 *
 */
__attribute__((unused)) static void commitEditing(id self, SEL cmd, UITableView * tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath * indexPath);
/**
 *
 */
__attribute__((unused)) static void scrollViewDidScroll(id self, SEL cmd, UIScrollView * scrollView);
/**
 *
 */
__attribute__((unused)) static void cellWillDisplay(id self, SEL cmd, UITableView *tableView,UITableViewCell *willDisplayCell,NSIndexPath *indexPath);

NS_ASSUME_NONNULL_END
