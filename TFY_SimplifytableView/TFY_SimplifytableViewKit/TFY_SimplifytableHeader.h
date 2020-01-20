//
//  TFY_SimplifytableHeader.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2019/6/12.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#ifndef TFY_SimplifytableHeader_h
#define TFY_SimplifytableHeader_h

#define TFY_DataArr(__dataArr__) ^(){return __dataArr__;}

#define TFY_CellClass(_cellClass_) [_cellClass_ class]

#define TFY_Adapter(_adapter_) \
^(__kindof UITableViewCell *cell,id data,NSIndexPath *indexPath){ \
_adapter_ \
}

#define TFY_Event(_event_) \
^(__kindof UITableView *tableView,NSIndexPath *indexPath,id data){ \
_event_ \
}

#define TFY_SectionCount(_count_) \
^NSUInteger(UITableView *tableView){ \
_count_ \
}

#define TFY_AddSectionMaker(_maker_) \
tableMaker.tfy_addSectionMaker(^(TFY_SectionMaker *sectionMaker) { \
_maker_ \
})

#define TFY_AddCellMaker(_maker_) \
sectionMaker.tfy_addCellMaker(^(TFY_CellMaker *cellMaker) { \
_maker_ \
})

#import "TFY_BaseTableViewDataSource.h"
#import "UITableView+TFY_TableViewMaker.h"

/**
 UITableView的Style为Plain时，当tableView上移顶端的tableHeaderView会跟着滑出窗口，而headerInsectionView则会悬浮固定在窗口顶端不随着滑动继续上移。
UITableView的Style为Grouped时，当tableView上移顶端的tableHeaderView会跟着滑出窗口，而headerInsectionView则会随着滑动继续上移。
UITableView的Style为Plain时禁止headerInsectionView固定在顶端：
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat sectionHeaderHeight = 50;

    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {

        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0,0);

    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {

        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);

    }

}*/


#endif /* TFY_SimplifytableHeader_h */
