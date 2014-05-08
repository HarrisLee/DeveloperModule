//
//  MoreViewController.m
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:nil];
    
//    CAlertView *alert = [[CAlertView alloc] initWithTitle:@"标题" message:@"内痛" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"ssss", nil];
//    [alert show];
//    [alert release];
    m_table = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, 310, kViewWithNavNoTabbar - 60) style:UITableViewStylePlain];
    m_table.delegate = self;
    m_table.dataSource = self;
    m_table.showsVerticalScrollIndicator = NO;
    m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_table];
    [m_table release];
    
}

#pragma mark -----------------
#pragma mark UITableView Delegate/DataSource Method
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idetifier = @"idetifier";
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:idetifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idetifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 45)];
        bgView.backgroundColor = [UIColor yellowColor];
        [cell addSubview:bgView];
        [bgView release];
    }
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
