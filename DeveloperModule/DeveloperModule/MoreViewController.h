//
//  MoreViewController.h
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "CommonViewController.h"

@interface MoreViewController : CommonViewController <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *m_table;
}

@end
