//
//  UINavigationBar+Customer.m
//  DeveloperModule
//
//  Created by Cao JianRong on 13-10-23.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "UINavigationBar+Customer.h"

@implementation UINavigationBar (Customer)

- (void) drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:@"bac-1.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, 44)];
}

//大于等于5.0
-(void)loadNavigationBar
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bac-1.png"]
                                           forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
        //         [[UISearchBar appearance]setBackgroundImage: [UIImage imageNamed: @"searchBar.png"]];
    }
    else
    {
        [self setNeedsDisplay];
    }
}

@end
