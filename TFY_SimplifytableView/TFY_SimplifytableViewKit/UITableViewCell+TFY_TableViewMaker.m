//
//  UITableViewCell+TFY_TableViewMaker.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UITableViewCell+TFY_TableViewMaker.h"
#import "NSObject+Associated.h"
@implementation UITableViewCell (TFY_TableViewMaker)

-(NSIndexPath *)indexPath{
    NSIndexPath *indexPath=objc_getAssociatedObject(self, _cmd);
    return indexPath;
}
-(void)setIndexPath:(NSIndexPath *)indexPath{
    objc_setAssociatedObject(self, @selector(indexPath), indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableView *)tableView
{
    UITableView *curTableView = [self tfy_getAssociatedObjectWithKey:_cmd];
    if (curTableView) return curTableView;
    
    return curTableView;
}

- (void)setTableView:(UITableView *)tableView
{
    [self tfy_setAssociatedAssignObject:tableView key:@selector(tableView)];
}

- (void)reloadRow:(UITableViewRowAnimation)animation{
    [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
}
@end
