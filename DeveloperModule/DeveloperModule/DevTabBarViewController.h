//
//  DevTabBarViewController.h
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FouthViewController.h"
#import "MoreViewController.h"

@interface DevTabBarViewController : UITabBarController <UIAlertViewDelegate>
{
    NSArray                         *m_CtrArray;                //控制器数组
    NSMutableArray                  *m_ButtonArray;             //按钮数组
    NSArray                         *m_NameArray;               //命名数组
    HomeViewController              *homeViewCtr;
    SecondViewController            *secViewCtr;
    ThirdViewController             *thirdViewCtr;
    FouthViewController             *fouthViewCtr;
    MoreViewController              *moreViewCtr;
}
@end