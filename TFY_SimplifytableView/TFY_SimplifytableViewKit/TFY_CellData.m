//
//  TFY_CellData.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_CellData.h"
#import "TFY_AutoLayout.h"
#import "UITableViewCell+TFY_TableViewMaker.h"
#import "UITableView+TFY_TableViewMaker.h"

@implementation TFY_CellData

-(UITableViewCell *)getReturnCell{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellidentifier forIndexPath:self.indexPath];
    cell.tableView = self.tableView;
    cell.indexPath = self.indexPath;
    if (_adapter) {
        _adapter(cell,_data,_indexPath);
    }
    return cell;
}


-(NSString *)cellidentifier{
    if (!_cellidentifier) {
        _cellidentifier = NSStringFromClass(_cell);
    }
    return _cellidentifier;
}

-(void)setCell:(Class)cell{
    _cell = cell;
    if (!self.tableView.tableViewRegisterCell[self.cellidentifier]) {//如果没有注册过
        UINib *nib = [UINib nibWithNibName:self.cellidentifier bundle:nil];
        if (self.cellRegisterType==CellRegisterTypeClass) {
            [self.tableView registerClass:[cell class] forCellReuseIdentifier:self.cellidentifier];
        }else{
            [self.tableView registerNib:nib forCellReuseIdentifier:self.cellidentifier];
        }
        
        [self.tableView.tableViewRegisterCell setValue:@(YES) forKey:self.cellidentifier];
    }
}

-(CGFloat)rowHeight{
    if (self.isAutoHeight) {
       
       _rowHeight =  [UITableViewCell tfy_CellHeightForIndexPath:_indexPath tableView:self.tableView identifier:self.cellidentifier layoutBlock:^(UITableViewCell * _Nonnull cell) {
           if (self.adapter) {
               self.adapter(cell,self.data,self.indexPath);
           }
        }];
//        _rowHeight = [self.tableView tfy_heightForCellWithIdentifier:self.cellidentifier cacheByIndexPath:_indexPath configuration:^(id cell) {
//            if (self.adapter) {
//                self.adapter(cell,self.data,self.indexPath);
//            }
//        }];
    }
    return _rowHeight+20;
}

@end

@implementation TFY_CellMaker

- (instancetype)initWithTableView:(UITableView *)tableView{
    self = [super init];
    if (self) {
        self.cellData.tableView = tableView;
    }
    return self;
    
}

- (NSIndexPath *)indexPath{
    return self.cellData.indexPath;
}

- (TFY_CellMaker * (^)(void))tfy_autoHeight {
    return ^TFY_CellMaker * {
        self.cellData.isAutoHeight = YES;
        return self;
    };
}

- (TFY_CellMaker * (^)(CGFloat))tfy_rowHeight{
    return ^TFY_CellMaker *(CGFloat height){
        self.cellData.rowHeight = height;
        return self;
    };
}

- (TFY_CellMaker * (^)(Class))tfy_cellClass {
    return ^TFY_CellMaker *(Class cell) {
        self.cellData.cellRegisterType = CellRegisterTypeClass;
        self.cellData.cell = cell;
        return self;
    };
}

- (TFY_CellMaker * (^)(Class))tfy_cellClassXib {
    return ^TFY_CellMaker *(Class cell) {
        self.cellData.cellRegisterType = CellRegisterTypeXib;
        self.cellData.cell = cell;
        return self;
    };
}

- (TFY_CellMaker * (^)(id))tfy_data {
    return ^TFY_CellMaker *(id data) {
        self.cellData.data = data;
        return self;
    };
}

- (TFY_CellMaker * (^)(CellAdapterBlock))tfy_adapter {
    return ^TFY_CellMaker *(CellAdapterBlock adapterBlock) {
        self.cellData.adapter = adapterBlock;
        return self;
    };
}

- (TFY_CellMaker * (^)(Class,CellAdapterBlock))tfy_cellClassAndAdapter{
    return ^TFY_CellMaker *(Class cell,CellAdapterBlock adapterBlock) {
        self.cellData.cell = cell;
        self.cellData.adapter = adapterBlock;
        return self;
    };
}
- (TFY_CellMaker * (^)(CellEventBlock))tfy_event {
    return ^TFY_CellMaker *(CellEventBlock event) {
        self.cellData.event = event;
        return self;
    };
}

- (TFY_CellData *)cellData
{
    if (!_cellData) {
        _cellData = [TFY_CellData new];
    }
    return _cellData;
}

@end
