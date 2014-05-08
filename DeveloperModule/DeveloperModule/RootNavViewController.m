//
//  RootNavViewController.m
//  eCity
//
//  Created by q mm on 12-11-16.
//  Copyright (c) 2012年 q mm. All rights reserved.
//

#import "RootNavViewController.h"

@interface RootNavViewController ()

@end

@implementation RootNavViewController

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

    [self fromLoginToHome];
    
    UINavigationBar *bar = self.navigationBar;
    [bar setBarStyle:UIBarStyleDefault];
    [bar loadNavigationBar];
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//        
//    for (UIView *obj in bar.subviews) {
//        NSString *name = [NSString stringWithFormat:@"%s",object_getClassName(obj)];
//        NSString *navBackName;
//        if (version <6.0) {
//            navBackName = @"UINavigationBarBackground";
//        }
//        else {
//            navBackName = @"_UINavigationBarBackground";
//        }
//        if ([name isEqualToString:navBackName]) {
//            UIImageView *barImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
//            barImageView.image = [[UIImage imageNamed:@"bac-1"] stretchableImageWithLeftCapWidth:320 topCapHeight:44];
//            [obj addSubview:barImageView];
//            [barImageView release];
//        }
//    }
    
    //改变导航栏表同意的字体颜色  方法一：
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"ArialMT" size:20],UITextAttributeFont,kGOLDCOLOR,UITextAttributeTextColor,nil];
    self.navigationBar.titleTextAttributes = dict;
    
    //改变导航栏表同意的字体颜色  方法二：
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 220, 44)];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.text = self.title;
//    titleLabel.textColor = GOLDCOLOR;
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.navigationItem.titleView = titleLabel;
//    [titleLabel release];
}

#pragma mark -
#pragma mark ViewJumpManagerDelegate
- (void)fromLoginToHome {
    [self popToRootViewControllerAnimated:NO];
    m_DevTabbarCtr = [[DevTabBarViewController alloc] init];
//    m_DevTabbarCtr.m_Delegate = self;
    [self pushViewController:m_DevTabbarCtr animated:YES];
    [m_DevTabbarCtr release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
