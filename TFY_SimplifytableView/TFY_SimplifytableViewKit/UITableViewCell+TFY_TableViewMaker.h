//
//  UITableViewCell+TFY_TableViewMaker.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (TFY_TableViewMaker)
/**
 *
 */
@property (nonatomic,weak) UITableView *tableView;
/**
 *
 */
@property (nonatomic, strong) NSIndexPath *indexPath;
/**
 *
 */
- (void)reloadRow:(UITableViewRowAnimation)animation;
@end

NS_ASSUME_NONNULL_END
