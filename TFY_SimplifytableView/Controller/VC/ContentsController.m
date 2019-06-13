//
//  ContentsController.m
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/6/13.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "ContentsController.h"
#import "ContentsTableViewCell.h"

@interface ContentsController ()
@property(nonatomic , strong)UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, copy) NSArray *keys;
@end

@implementation ContentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"联系人分组";
    
    self.view.backgroundColor = [UIColor tfy_colorWithHex:@"fafafa"];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
    
    [self dataLayout];
}

-(void)dataLayout{
    [[TFY_ContactManager sharedInstance] accessSectionContactsComplection:^(BOOL succeed, NSArray<TFY_SectionPerson *> * _Nonnull contacts, NSArray<NSString *> * _Nonnull keys) {
        
        self.dataSource = contacts;
        self.keys = keys;
        
        [self tableViewLayout];
        
        [self.tableView reloadData];
        
    }];
}
-(void)tableViewLayout{
    [self.tableView tfy_tableViewMaker:^(TFY_TableViewMaker * _Nonnull tableMaker) {
        
        [tableMaker.tfy_sectionCount(self.dataSource.count).tfy_sectionIndexArr(self.keys) tfy_sectionMaker:^(TFY_SectionMaker * _Nonnull sectionMaker) {
            
            sectionMaker.tfy_headerHeight(20);
            
            TFY_SectionPerson *sectionModel = self.dataSource[[sectionMaker section]];
            sectionMaker.tfy_headerTitle(sectionModel.key);
            
            [sectionMaker.tfy_dataArr(^(void){
                TFY_SectionPerson *sectionModel = self.dataSource[[sectionMaker section]];
                return sectionModel.persons;
                
            }) tfy_cellMaker:^(TFY_CellMaker * _Nonnull cellMaker) {
                
                cellMaker.tfy_cellClass(TFY_CellClass(ContentsTableViewCell))
                .tfy_adapter(^(__kindof ContentsTableViewCell *cell,TFY_PersonModel *model,NSIndexPath *iindexPath){
                    cell.model = model;
                })
                .tfy_rowHeight(60);
            }];
        }];
    }];
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorColor = [UIColor tfy_colorWithHex:@"F6F7FD"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    return _tableView;
}


@end
