//
//  TFY_SimplifytableViewKit.h
//  TFY_SimplifytableView
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 恋机科技. All rights reserved.
//  最新版本号：

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double TFY_SimplifytableViewKitVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_SimplifytableViewKitVersionString[];

#define TFY_SimplifytableViewKitRelease 0

#if TFY_SimplifytableViewKitRelease

#import <TFY_SimplifytableViewKit/TFY_BaseTableViewDataSource.h>
#import <TFY_SimplifytableViewKit/UITableView+TFY_TableViewMaker.h>

#else

#import "TFY_BaseTableViewDataSource.h"
#import "UITableView+TFY_TableViewMaker.h"

#endif


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
