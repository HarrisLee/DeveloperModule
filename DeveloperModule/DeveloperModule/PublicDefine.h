//
//  PublicDefine.h
//  eCity
//
//  Created by xuchuanyong on 11/21/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//
//公用定义类
#ifndef eCity_PublicDefine_h
#define eCity_PublicDefine_h
#import <Foundation/Foundation.h>

#import "CActivityIndicatorView.h"
#import "CAlertView.h"
//界面跳转控制协议，同意回调到根视图控制器进行跳转
@protocol ViewJumpManagerDelegate <NSObject>
@optional
-(void)fromWelcome;
//从登录界面跳转到主页
- (void)fromLoginToHome;
//游客登录后回到登录界面
- (void)guestBackLogin;
//前往二级菜单
- (void)gotoSecondaryMenu;
//前往应用专题
- (void)gotoMoreTheme;

- (void)gotoEFamily;

- (void)gotoChangePass;

//- (void)gotoChangeInfo:(GetUserDataRespBody*)userData;

@end

#define APP_LIST_UPDATE         @"AppListUpdate"

#define TRAVEL_UPDATE           @"travelUpdate"

#define mainScreenBounds        [UIScreen mainScreen].bounds

#define viewWithNavAndTabbar    mainScreenBounds.size.height-20-44-50

#define viewWithNavNoTabbar     mainScreenBounds.size.height-20-44

#define viewWithTabbarNoNav     mainScreenBounds.size.height-20-50

#define viewWithNothing         mainScreenBounds.size.height-20

#define GOLDCOLOR               [UIColor colorWithRed:102.0f/255.0f green:51.0f/255.0f blue:0.0f alpha:1.0f]

#define LIGHT_GOLD              [UIColor colorWithRed:232.0f/255.0f green:213.0f/255.0f blue:38.0f/255.0f alpha:0.8f]


#endif
