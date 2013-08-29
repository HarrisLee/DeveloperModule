//
//  DevTabBarViewController.m
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "DevTabBarViewController.h"

@interface DevTabBarViewController ()

@end

@implementation DevTabBarViewController
#define IMAGE_VIEW_TAG          11111
#define LABEL_VIEW_TAG          22222

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setNav:(UINavigationController*)navCtr {
    UINavigationBar *bar = navCtr.navigationBar;
    [bar setBarStyle:UIBarStyleDefault];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    for (UIView *obj in bar.subviews) {
        NSString *name = [NSString stringWithFormat:@"%s",object_getClassName(obj)];
        NSString *navBackName;
        if (version <6.0) {
            navBackName = @"UINavigationBarBackground";
        }
        else {
            navBackName = @"_UINavigationBarBackground";
        }
        if ([name isEqualToString:navBackName]) {
            UIImageView *barImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
            barImageView.image = [[UIImage imageNamed:@"bac-1"] stretchableImageWithLeftCapWidth:320 topCapHeight:44];
            [obj addSubview:barImageView];
            [barImageView release];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:YES];
    [self.selectedViewController viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImage* image= [UIImage imageNamed:@"button-back"];
    CGRect frame= CGRectMake(0, 0, 40, 30);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:someBarButtonItem];
    [someBarButtonItem release];
    [backButton release];
    
    frame= CGRectMake(10, 12, 41, 32);
    UIButton* rightButton= [[UIButton alloc] initWithFrame:frame];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"search_button_down.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(popMenuView) forControlEvents:UIControlEventTouchUpInside];
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem *rightBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    [rightBarButtonItem release];
    [rightButton release];
    // Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    m_ButtonArray = [[NSMutableArray alloc] init];
    m_NameArray = [[NSArray alloc] initWithObjects:@"E家通",@"资讯",@"悠游舟山",@"下载",@"更多", nil];
    
    //改变导航栏表同意的字体颜色  方法一：
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"ArialMT" size:20],UITextAttributeFont,GOLDCOLOR,UITextAttributeTextColor,nil];
    
    homeViewCtr = [[HomeViewController alloc] init];
    homeViewCtr.m_Delegate = appDelegate.m_RootNavCtr;
    UINavigationController *HomeNav = [[UINavigationController alloc] initWithRootViewController:homeViewCtr];
    [homeViewCtr release];
    homeViewCtr.title = @"E家通";
    HomeNav.tabBarItem.image = [UIImage imageNamed:@"gold_menu_1"];
    HomeNav.navigationBar.titleTextAttributes = dict;
    
    secViewCtr = [[SecondViewController alloc] init];
    secViewCtr.m_Delegate = appDelegate.m_RootNavCtr;
    UINavigationController *secNav = [[UINavigationController alloc] initWithRootViewController:secViewCtr];
    [secViewCtr release];
    secViewCtr.title = @"资讯";
    secNav.tabBarItem.image = [UIImage imageNamed:@"gold_menu_2"];
    secNav.navigationBar.titleTextAttributes = dict;
    
    thirdViewCtr = [[ThirdViewController alloc] init];
    thirdViewCtr.m_Delegate = appDelegate.m_RootNavCtr;
    UINavigationController *thirdNav = [[UINavigationController alloc] initWithRootViewController:thirdViewCtr];
    [thirdViewCtr release];
    thirdViewCtr.title = @"悠游舟山";
    thirdNav.tabBarItem.image = [UIImage imageNamed:@"gold_menu_3"];
    thirdNav.navigationBar.titleTextAttributes = dict;
    
    fouthViewCtr = [[FouthViewController alloc] init];
    fouthViewCtr.m_Delegate = appDelegate.m_RootNavCtr;
    UINavigationController *fouNav = [[UINavigationController alloc] initWithRootViewController:fouthViewCtr];
    [fouthViewCtr release];
    fouthViewCtr.title = @"下载";
    fouNav.tabBarItem.image = [UIImage imageNamed:@"gold_menu_4"];
    fouNav.navigationBar.titleTextAttributes = dict;
    
    moreViewCtr = [[MoreViewController alloc] init];
    moreViewCtr.m_Delegate = appDelegate.m_RootNavCtr;
    UINavigationController *moreNav = [[UINavigationController alloc] initWithRootViewController:moreViewCtr];
    [moreViewCtr release];
    moreViewCtr.title = @"更多";
    moreNav.tabBarItem.image = [UIImage imageNamed:@"gold_menu_5"];
    moreNav.navigationBar.titleTextAttributes = dict;
    
    m_CtrArray = [[NSArray alloc]initWithObjects:HomeNav,secNav,thirdNav,fouNav,moreNav, nil];
    
    for (UINavigationController *nav in m_CtrArray) {
        [self setNav:nav];
    }
    
    self.viewControllers = m_CtrArray;
    
    [HomeNav release];
    [secNav release];
    [thirdNav release];
    [fouNav release];
    [moreNav release];
    [m_CtrArray release];
    
    [self setCustomTabBar];
}

//自定义tabbar切换实现
- (void)tabBarChangeSelected:(UIButton*)btn {

    for (UIButton *sender in m_ButtonArray) {
        [sender setSelected:NO];
        UIImageView *img = (UIImageView*)[sender viewWithTag:IMAGE_VIEW_TAG];
        [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"gold_menu_%d",sender.tag+1]]];
        UILabel *label = (UILabel*)[sender viewWithTag:LABEL_VIEW_TAG];
        [label setTextColor:[UIColor grayColor]];
    }
    [btn setSelected:YES];
    UIImageView *img = (UIImageView*)[btn viewWithTag:IMAGE_VIEW_TAG];
    [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"gold_menu_%d_v",btn.tag+1]]];
    [(UILabel*)[btn viewWithTag:LABEL_VIEW_TAG] setTextColor:[UIColor whiteColor]];
    self.selectedIndex = btn.tag;
}

//创建自定义tabbar
- (void)setCustomTabBar {
    UIImageView *tabBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    tabBarView.image = [UIImage imageNamed:@"BAC-1"];
    tabBarView.userInteractionEnabled = YES;
    [tabBarView setBackgroundColor:[UIColor blackColor]];

    [self.tabBar addSubview:tabBarView];
    for (int i = 0;i<[m_CtrArray count];i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/[m_CtrArray count]*i, 0,self.view.bounds.size.width/[m_CtrArray count] , 50)];
        btn.tag = i;
        [btn addTarget:self action:@selector(tabBarChangeSelected:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *barImage = [[UIImageView alloc] init];//WithFrame:CGRectMake(15, 0, btn.frame.size.width-30, btn.frame.size.height-14)];
        barImage.center = CGPointMake(btn.frame.size.width/2, btn.frame.size.height/2-4);
        barImage.tag = IMAGE_VIEW_TAG;
        barImage.clipsToBounds = NO;
        barImage.contentMode = UIViewContentModeCenter;
        barImage.transform = CGAffineTransformMakeScale(0.52, 0.52);
        barImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"gold_menu_%d",i+1]];
        [btn addSubview:barImage];
        [barImage release];
        
        [tabBarView addSubview:btn];
        [m_ButtonArray addObject:btn];
        [btn release];
    }
    [tabBarView release];
    [self tabBarChangeSelected:[m_ButtonArray objectAtIndex:0]];
}

- (void)alertView:(CAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //        NSLog(@"已调用");
        [self loginBtnClicked];
    }
}

-(void) popMenuView
{
    NSLog(@"12345");
}

-(void) goBack
{
    NSLog(@"123456");
}

-(void) loginBtnClicked
{
    NSLog(@"1234567");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
