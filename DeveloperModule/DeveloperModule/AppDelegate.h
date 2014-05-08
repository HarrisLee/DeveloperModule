//
//  AppDelegate.h
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootNavViewController.h"
#import "UINavigationBar+Customer.h"
//#import "GetLocationInfo.h"
//#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    RootNavViewController *m_RootNavCtr;
    CAlertView            *alert;
    BOOL                  pushLaunch;
    NSString              *_valuePush;
    NSDictionary          *recDic;        //推送内容接收字典
//    BMKMapManager* _mapManager;
//    GetLocationInfo         *location;           //获取位置对象
}

@property (strong, nonatomic) UIWindow *window;

@property (retain,nonatomic)  RootNavViewController *m_RootNavCtr;

@property (retain, nonatomic) NSString *valuePush;

@end
