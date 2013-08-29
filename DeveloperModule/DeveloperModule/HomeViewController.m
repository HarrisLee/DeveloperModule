//
//  HomeViewController.m
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) popMenuView
{
    NSLog(@"12345678ssssss");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setLeftBarButtonItem:nil];
    CGRect frame= CGRectMake(10, 12, 41, 32);
    UIButton* rightButton= [[UIButton alloc] initWithFrame:frame];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"search_button_down.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(popMenuView) forControlEvents:UIControlEventTouchUpInside];
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem *rightBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    [rightBarButtonItem release];
    [rightButton release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
