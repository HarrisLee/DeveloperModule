//
//  RootNavViewController.h
//  eCity
//
//  Created by q mm on 12-11-16.
//  Copyright (c) 2012年 q mm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevTabBarViewController.h"
//#import "LoginViewController.h"
//#import "ECityTabBarViewController.h"
//#import "WelcomeViewController.h"
//#import "GetLocationInfo.h"
//#import "ThemeViewController.h"
//#import "eFamilyViewController.h"

@interface RootNavViewController : UINavigationController <ViewJumpManagerDelegate,UIAlertViewDelegate>
{
//    LoginViewController         *m_LoginCtr;            //登录界面controller
    DevTabBarViewController   *m_DevTabbarCtr;      //应用总tabbarController
//    WelcomeViewController       *m_WelCtr;
//    ThemeViewController         *m_ThemeCtr;
//     NSString                *newVersionLocal;
}

@end
