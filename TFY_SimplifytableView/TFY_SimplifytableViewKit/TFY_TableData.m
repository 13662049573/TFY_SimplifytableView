//
//  TFY_TableData.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_TableData.h"

#import "TFY_SectionData.h"

#define StringSelector(_SEL_) NSStringFromSelector(@selector(_SEL_))

@implementation TFY_TableData
@synthesize sectionCount = _sectionCount;

-(instancetype)initWithTableView:(UITableView *)tableView{
    self = [super init];
    if (self) {
        self.tableView = tableView;
    }
    return self;
}

-(NSUInteger)sectionCount{
    
    if (self.sectionCountBlock) {
        [self setSectionCount:self.sectionCountBlock(self.tableView)];
    }
    
    if (0==_sectionCount&&self.sectionDatas.count>0) {
        [self setSectionCount:self.sectionDatas.count];
    }
    
    return _sectionCount;
}

-(void)setSectionCount:(NSUInteger)sectionCount{
    _sectionCount = sectionCount;
}

-(NSMutableArray<TFY_SectionData *> *)sectionDatas{
    if (!_sectionDatas) {
        _sectionDatas = [NSMutableArray array];
    }
    return _sectionDatas;
}

-(void)setSectionMakeBlock:(SectionMakeBlock)sectionMakeBlock{
    _sectionMakeBlock = sectionMakeBlock;
}

-(void)doSectionMakeBlock{
    if (self.sectionCount>0&&self.sectionMakeBlock) {
        [_sectionDatas removeAllObjects];
        TFY_SectionMaker * sectionMaker = nil;
        for (NSUInteger i = 0; i<self.sectionCount; i++) {
            sectionMaker = [[TFY_SectionMaker alloc] initWithTableView:self.tableView];
            if (self.rowHeight!=0) {
                sectionMaker.sectionData.rowHeight = self.rowHeight;
            }
            sectionMaker.sectionData.section = i;
            self.sectionMakeBlock(sectionMaker);
            [sectionMaker.sectionData doCellMakerBlock];
            [self.sectionDatas addObject:sectionMaker.sectionData];
        }
    }
}

- (void)doAddSectionMaker:(SectionMakeBlock)sectionMakerBlock{
    
    TFY_SectionMaker * sectionMaker = nil;
    
    sectionMaker = [[TFY_SectionMaker alloc] initWithTableView:self.tableView];
    if (self.rowHeight!=0) {
        sectionMaker.sectionData.rowHeight = self.rowHeight;
    }
    
    sectionMaker.sectionData.section = self.sectionCount;
    
    self.sectionCount = self.sectionCount + 1;
    
    sectionMakerBlock(sectionMaker);
    
    if (!sectionMaker.sectionData.isStaticCell) {
        [sectionMaker.sectionData doCellMakerBlock];
    }
    
    [self.sectionDatas addObject:sectionMaker.sectionData];
    
}

-(NSMutableDictionary *)otherDelegateBlocksDic{
    if (!_otherDelegateBlocksDic) {
        _otherDelegateBlocksDic = [NSMutableDictionary dictionary];
    }
    return _otherDelegateBlocksDic;
}

@end

@implementation TFY_TableViewMaker

- (instancetype)initWithTableView:(UITableView *)tableView{
    self = [super init];
    if (self) {
        self.tableData.tableView = tableView;
    }
    return self;
    
}
- (instancetype)initWithTableData:(TFY_TableData *)tableData{
    self = [super init];
    if (self) {
        self.tableData = tableData;
    }
    return self;
    
}

- (TFY_TableViewMaker * (^)(UIView * (^)(void)))tfy_tableViewHeaderView {
    return ^TFY_TableViewMaker *(UIView * (^view)(void)) {
        UIView * headerView =  view();
        [self.tableData.tableView.tableHeaderView layoutIfNeeded];
        self.tableData.tableView.tableHeaderView = headerView;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(UIView * (^)(void)))tfy_tableViewFooterView {
    return ^TFY_TableViewMaker *(UIView * (^view)(void)) {
        UIView * footerView =  view();
        [self.tableData.tableView.tableFooterView layoutIfNeeded];
        self.tableData.tableView.tableFooterView = footerView;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(CGFloat))tfy_height {
    return ^TFY_TableViewMaker *(CGFloat height) {
        self.tableData.rowHeight = height;
        self.tableData.tableView.rowHeight = height;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(NSInteger))tfy_sectionCount {
    return ^TFY_TableViewMaker *(NSInteger sectionCount) {
        self.tableData.sectionCount = sectionCount;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(SectionCountBlock))tfy_sectionCountBk{
    return ^TFY_TableViewMaker *(SectionCountBlock sectionCountBlock){
        self.tableData.sectionCountBlock = sectionCountBlock;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(SectionMakeBlock))tfy_sectionMaker{
    return ^TFY_TableViewMaker *(SectionMakeBlock sectionMakeBlock){
        self.tableData.sectionMakeBlock = sectionMakeBlock;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(SectionMakeBlock))tfy_addSectionMaker{
    return ^TFY_TableViewMaker *(SectionMakeBlock sectionMakeBlock){
        [self.tableData doAddSectionMaker:sectionMakeBlock];
        return self;
    };
}

- (TFY_TableViewMaker *)tfy_sectionMaker:(SectionMakeBlock)sectionMakeBlock{
    self.tableData.sectionMakeBlock = sectionMakeBlock;
    return self;
}

- (TFY_TableViewMaker *)tfy_addSectionMaker:(SectionMakeBlock)sectionMakeBlock{
    [self.tableData doAddSectionMaker:sectionMakeBlock];
    return self;
}


- (TFY_TableViewMaker * (^)(CellWillDisplayBlock))tfy_cellWillDisplay{
    return ^TFY_TableViewMaker *(CellWillDisplayBlock cellWillDisplayBlock){
        self.tableData.otherDelegateBlocksDic[StringSelector(tableView:willDisplayCell:forRowAtIndexPath:)] = cellWillDisplayBlock;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(CommitEditingBlock))tfy_commitEditing{
    return ^TFY_TableViewMaker *(CommitEditingBlock commitEditingBlock){
        self.tableData.otherDelegateBlocksDic[StringSelector(tableView:commitEditingStyle:forRowAtIndexPath:)] = commitEditingBlock;
        return self;
    };
}

- (TFY_TableViewMaker * (^)(ScrollViewDidScrollBlock))tfy_scrollViewDidScroll{
    return ^TFY_TableViewMaker *(ScrollViewDidScrollBlock scrollViewDidScrollBlock){
        self.tableData.otherDelegateBlocksDic[StringSelector(scrollViewDidScroll:)] = scrollViewDidScrollBlock;
        return self;
    };
}

- (TFY_TableData *)tableData
{
    if (!_tableData) {
        _tableData = [TFY_TableData new];
    }
    return _tableData;
}

@end
