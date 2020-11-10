//
//  ViewController.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/5/29.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"
#import "ViewHerderView.h"
#import "ViewTableViewCell.h"
#import "ModeldetailController.h"
@interface ViewController ()
@property(nonatomic , strong)UITableView *tableView;

@property(nonatomic , strong)ViewModel *model;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TFY_SimplifytableViewKit分组展示";
    
    self.view.backgroundColor = [UIColor tfy_colorWithHex:@"ffffff"];
    
    [self data];
}
-(void)data{
    RACCommandData *data = [RACCommandData new];
    [[data.viewModelCommand execute:@1] subscribeNext:^(id  _Nullable x) {
        
        self.model = x;
        
        [self tableView];
        
        [self.tableView reloadData];
        
    }];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorColor = [UIColor tfy_colorWithHex:@"F6F7FD"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        [self.view addSubview:_tableView];
        
        [_tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
        
        [_tableView tfy_tableViewMaker:^(TFY_TableViewMaker * _Nonnull tableMaker) {
            [tableMaker.tfy_sectionCount(self.model.data.count) tfy_sectionMaker:^(TFY_SectionMaker * _Nonnull sectionMaker) {
                //添加组头
                sectionMaker.tfy_headerView(^(){
                    ViewHerderView *herder = [[ViewHerderView alloc] initWithFrame:CGRectMake(0, 0, Width_W, 40)];
                    herder.models = self.model.data[[sectionMaker section]];
                    return herder;
                });
                //添加j数据TFY_DataArr
                [sectionMaker.tfy_dataArr(^(void){
                    
                    Data *model = self.model.data[[sectionMaker section]];
                    return model.prod_list;
                    
                }) tfy_cellMaker:^(TFY_CellMaker *cellMaker){//添加cell 高度
                    
                    cellMaker.tfy_cellClass([ViewTableViewCell class])//添加cell
                    .tfy_adapter(^(__kindof ViewTableViewCell *cell,Prod_list *model,NSIndexPath *iindexPath){//cell 赋值
                        
                        cell.models = model;
                    })
                    .tfy_event(^(__kindof UITableView *tableView,NSIndexPath *indexpath,Prod_list *models){//点击方法
                        
                        ModeldetailController *vc = [ModeldetailController new];
                        vc.models = models;
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    })
                    .tfy_autoHeight();
                    
                }];
            }];
        }];
    }
    return _tableView;
}

@end
