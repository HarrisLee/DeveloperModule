//
//  DataCenter.h
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

//数据中心，用于保存一些整个应用全局的标志或者数据
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "UserInfo.h"
#import <CoreLocation/CoreLocation.h>
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"

@interface DataCenter : NSObject <UIAlertViewDelegate,ISSShareViewDelegate,ISSViewDelegate>{
    BOOL            isGuest;                     //是否游客
    NSDictionary            *configDictionary;   //配置字典
    NSDictionary            *errorDictionary;    //错误码字典
    UserInfo                *userInfo;           //登录成功后保存用户信息
    NSString                *city;
    CLLocationCoordinate2D  localInfo;
    ShareType               willShareType;      //将要分享的类型
    
}
@property (nonatomic,retain) NSDictionary           *configDictionary;
@property (nonatomic,retain) NSDictionary           *errorDictionary;
@property (nonatomic,retain) UserInfo               *userInfo;
@property (nonatomic,retain) NSString               *city;
@property (nonatomic,assign) CLLocationCoordinate2D localInfo;

+ (DataCenter*)shareInstance;
+ (NSString*)saveImageFile:(UIImage*)image;

- (void)initShareSDK;

- (void)shareContent:(id)content withSender:(id)sender;
- (void)shareContent:(NSString*)content title:(NSString*)title url:(NSString*)url image:(NSString*)imageUrl withSender:(id)sender;

@end
