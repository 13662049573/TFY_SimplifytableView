//
//  TFY_SectionData.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_SectionData.h"

@implementation TFY_SectionData
@synthesize rowCount = _rowCount;

-(CGFloat)headerHeight{
    if (_headerHeight==0) {
        _headerHeight = 0.0001;
        if (self.headerView) {
            _headerHeight = _headerView.frame.size.height;
        }
        if (self.headerTitle) {
            _headerHeight = 30;
        }
    }
    return _headerHeight;
}

-(CGFloat)footerHeight{
    if (_footerHeight==0) {
        _footerHeight = 0.0001;
        if (self.footerView) {
            _headerHeight = _footerView.frame.size.height;
        }
        if (self.footerTitle) {
            _headerHeight = 30;
        }
    }
    
    return _footerHeight;
}

-(NSUInteger)rowCount{
    return _rowCount;
}

-(void)setRowCount:(NSUInteger)rowCount{
    _rowCount = rowCount;
}

-(void)setCellMakeBlock:(CellMakeBlock)cellMakeBlock{
    _cellMakeBlock = cellMakeBlock;
}

-(void)doCellMakerBlock{
    if ((self.rowCount>0||self.modelDatas.count>0)&&self.cellMakeBlock) {
        [_cellDatas removeAllObjects];
        TFY_CellMaker * cellMaker = nil;
        NSUInteger count = self.modelDatas.count>0?self.modelDatas.count:self.rowCount;
        for (NSUInteger i = 0; i < count; i++) {
            cellMaker = [[TFY_CellMaker alloc] initWithTableView:self.tableView];
            cellMaker.cellData.indexPath = [NSIndexPath indexPathForRow:i inSection:self.section];
            cellMaker.cellData.data = self.modelDatas[i];
            cellMaker.cellData.rowHeight = self.rowHeight;
            self.cellMakeBlock(cellMaker);
            [self.cellDatas addObject:cellMaker.cellData];
        }
    }
    
}

- (void)doAddCellMakerBlock:(CellMakeBlock)cellMakerBlock{
    if (!self.isStaticCell) {
        self.isStaticCell = YES;
    }
    TFY_CellMaker * cellMaker = nil;
    cellMaker = [[TFY_CellMaker alloc] initWithTableView:self.tableView];
    cellMaker.cellData.indexPath = [NSIndexPath indexPathForRow:self.rowCount inSection:self.section];
    self.rowCount = self.rowCount + 1;
    cellMaker.cellData.rowHeight = self.rowHeight;
    cellMakerBlock(cellMaker);
    [self.cellDatas addObject:cellMaker.cellData];
    
}

-(NSArray *)modelDatas{
    if (self.getDataBlock) {
        _modelDatas = self.getDataBlock();
    }
    return _modelDatas;
}

-(NSMutableArray<TFY_CellData *> *)cellDatas{
    if (!_cellDatas) {
        _cellDatas = [NSMutableArray array];
    }
    return _cellDatas;
}
@end

@implementation TFY_SectionMaker

- (instancetype)initWithTableView:(UITableView *)tableView{
    self = [super init];
    if (self) {
        self.sectionData.tableView = tableView;
    }
    return self;
    
}

- (NSUInteger)section{
    return self.sectionData.section;
}

- (TFY_SectionMaker * (^)(NSString *))tfy_headerTitle {
    return ^TFY_SectionMaker *(NSString * title) {
        self.sectionData.headerTitle = title;
        return self;
    };
}

- (TFY_SectionMaker * (^)(NSString *))tfy_footerTitle {
    return ^TFY_SectionMaker *(NSString * title) {
        self.sectionData.footerTitle = title;
        return self;
    };
}

- (TFY_SectionMaker * (^)(CGFloat))tfy_rowHeight{
    return ^TFY_SectionMaker *(CGFloat height){
        self.sectionData.rowHeight = height;
        return self;
    };
}

- (TFY_SectionMaker * (^)(CGFloat))tfy_headerHeight{
    return ^TFY_SectionMaker *(CGFloat height){
        self.sectionData.headerHeight = height;
        return self;
    };
}

- (TFY_SectionMaker * (^)(CGFloat))tfy_footerHeight{
    return ^TFY_SectionMaker *(CGFloat height){
        self.sectionData.footerHeight = height;
        return self;
    };
}


- (TFY_SectionMaker * (^)(UIView * (^)(void)))tfy_headerView {
    return ^TFY_SectionMaker *(UIView * (^view)(void)) {
        self.sectionData.headerView = view();
        return self;
    };
}

- (TFY_SectionMaker * (^)(GetDataBlock))tfy_dataArr{
    return ^TFY_SectionMaker *(GetDataBlock getDataBlock){
        self.sectionData.getDataBlock = getDataBlock;
        return self;
    };
}

- (TFY_SectionMaker * (^)(UIView * (^)(void)))tfy_footerView {
    return ^TFY_SectionMaker *(UIView * (^view)(void)) {
        self.sectionData.footerView = view();
        return self;
    };
}

- (TFY_SectionMaker * (^)(NSInteger))tfy_rowCount{
    return ^TFY_SectionMaker *(NSInteger rowCount){
        self.sectionData.rowCount = rowCount;
        return self;
    };
}

- (TFY_SectionMaker * (^)(CellMakeBlock))tfy_cellMaker{
    return ^TFY_SectionMaker *(CellMakeBlock cellMakerBlock){
        self.sectionData.cellMakeBlock = cellMakerBlock;
        return self;
    };
}
- (TFY_SectionMaker * (^)(CellMakeBlock))tfy_addCellMaker{
    return ^TFY_SectionMaker *(CellMakeBlock cellMakerBlock){
        [self.sectionData doAddCellMakerBlock:cellMakerBlock];
        return self;
    };
}
- (TFY_SectionMaker *)tfy_cellMaker:(CellMakeBlock)cellMakerBlock{
    self.sectionData.cellMakeBlock = cellMakerBlock;
    return self;
}

- (TFY_SectionMaker *)tfy_addCellMaker:(CellMakeBlock)cellMakerBlock{
    [self.sectionData doAddCellMakerBlock:cellMakerBlock];
    return self;
}

- (TFY_SectionData *)sectionData {
    if (! _sectionData) {
        _sectionData = [TFY_SectionData new];
    }
    return _sectionData;
}

@end
