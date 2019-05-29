//
//  TFY_BaseTableViewDataSource.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_BaseTableViewDataSource.h"
#import <objc/runtime.h>

#import "TFY_SectionData.h"
#import "TFY_TableData.h"
#import "TFY_CellData.h"


@implementation TFY_BaseTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableData.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableData.sectionDatas[(NSUInteger) section].rowCount==0) {
        return self.tableData.sectionDatas[(NSUInteger) section].modelDatas.count;
    }
    return self.tableData.sectionDatas[(NSUInteger) section].rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableData.sectionDatas[(NSUInteger) section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.tableData.sectionDatas[(NSUInteger) section].footerTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tableData.sectionDatas[(NSUInteger) section].headerView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.tableData.sectionDatas[(NSUInteger) section].footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.tableData.sectionDatas[(NSUInteger) section].headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.tableData.sectionDatas[(NSUInteger) section].footerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = (NSUInteger) indexPath.section;
    NSUInteger index = (NSUInteger) indexPath.row;
    
    TFY_SectionData *sectionData = self.tableData.sectionDatas[section];
    
    TFY_CellData *cellData = sectionData.cellDatas[index];
    
    return cellData.rowHeight;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = (NSUInteger) indexPath.section;
    NSUInteger index = (NSUInteger) indexPath.row;
    
    TFY_CellData *cellData = self.tableData.sectionDatas[section].cellDatas[index];
    
    return [cellData getReturnCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = (NSUInteger) indexPath.section;
    NSUInteger index = (NSUInteger) indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TFY_CellData *cellData = self.tableData.sectionDatas[section].cellDatas[index];
    
    if (cellData.event) {
        cellData.event(tableView,indexPath,cellData.data);
    }
    
}


@end
