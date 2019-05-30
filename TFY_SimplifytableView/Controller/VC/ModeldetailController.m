//
//  ModeldetailController.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ModeldetailController.h"
#import "ViewFooderView.h"
#import "ModeldetailTableViewCell.h"
@interface ModeldetailController ()
@property(nonatomic , strong)UITableView *tableView;

@end

@implementation ModeldetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"tableView没有分组展示";
    
    self.view.backgroundColor = [UIColor tfy_colorWithHex:@"fafafa"];
    
    
}

-(void)setModels:(Prod_list *)models{
    _models = models;
    
    [self tableView];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorColor = [UIColor tfy_colorWithHex:@"F6F7FD"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        [self.view addSubview:_tableView];
        
        [_tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
        
        [_tableView tfy_tableViewMaker:^(TFY_TableViewMaker * _Nonnull tableMaker) {
            //给主tableviwe添加投View
            tableMaker.tfy_tableViewHeaderView(^(){
                ViewFooderView *herder = [[ViewFooderView alloc] initWithFrame:CGRectMake(0, 0, Width_W, 40)];
                herder.model = self.models;
                return herder;
            });
            [tableMaker tfy_addSectionMaker:^(TFY_SectionMaker * _Nonnull sectionMaker) {
                
                [sectionMaker.tfy_dataArr(TFY_DataArr(self.models.model_detail)) tfy_cellMaker:^(TFY_CellMaker * _Nonnull cellMaker) {
                   
                    cellMaker.tfy_cellClass(TFY_CellClass(ModeldetailTableViewCell))
                    .tfy_adapter(^(__kindof ModeldetailTableViewCell *cell,Model_detail *data,NSIndexPath *indexPath){
                        
                        cell.models = data;
                    })
                    .tfy_autoHeight();
                    
                }];
                
            }];
            
        }];
    }
    return _tableView;
}

@end
