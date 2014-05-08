//
//  HttpRequestCenter.h
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataCenter.h"
#import "NetPublicDefine.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "ASIDownloadCache.h"
#import "ReqBody.h"
#import "RespBody.h"

#define UPLOADFILE       [NSString stringWithFormat:@"%@",[[DataCenter shareInstance].configDictionary objectForKey:@"文件服务器"]]

#define UPLOADFACE       [NSString stringWithFormat:@"http://taijiongle.com/receive_jpg.php"]


@protocol HttpRequestCenterDelegate <NSObject>

- (void)dataComBack:(RespBody*)response andReqType:(NSString*)reqType;

@end

@interface HttpRequestCenter : NSObject {
    NSDictionary        *urlDic;           //保存url字典
    NSDictionary        *respNameDic;      //返回类名字典
    NSDictionary        *errorCodeDic;     //错误码字典
    ASINetworkQueue     *m_Queue;          //网络请求队列
    ASINetworkQueue     *m_DownloadQueue;  //下载请求队列
    id                  NetBackTarget;               //网络返回调用对象
    SEL                 NetBackAction;              //网络返回调用函数
    
    NSTimer             *maskTimer;     //蒙板定时器
    UIView              *maskView;      //蒙板
    
    ASIDownloadCache *downloadCache;    //下载缓存策略
}

+(HttpRequestCenter*)shareInstance;

//根据时间显示蒙板
- (void)showMaskWithTimer:(NSTimeInterval)time onView:(UIView*)view;
//移除蒙板
- (void)removeMask;

//发送请求，使用函数调用方式
- (void)requestWithBody:(ReqBody*)reqBody andReqType:(NSString*)reqType withTarget:(id)target andAction:(SEL)action;
//是否使用蒙板
- (void)requestWithBody:(ReqBody*)reqBody andReqType:(NSString*)reqType withTarget:(id)target andAction:(SEL)action withMask:(BOOL)mask;

//拼接soap字符串
- (NSString*)appendSoapStr:(NSString*)string WithType:(NSString*)type;

//从网络请求图片，返回后直接设置到UIImageView，异步下载并进行缓存
- (void)requestImageWithUrl:(NSString*)imageUrl andImageView:(UIImageView*)imageView;

- (UIImage*)getImageWithUrl:(NSString*)imageUrl;

- (void)downloadFileWithUrl:(NSString*)url andPath:(NSString*)path withTarget:(id)target andAction:(SEL)action withProgress:(id)progress;
//下载时是否显示蒙板
- (void)downloadFileWithUrl:(NSString*)url andPath:(NSString*)path withTarget:(id)target andAction:(SEL)action withProgress:(id)progress withMask:(BOOL)mask;

- (void)uploadFileWithUrl:(NSString*)url andPath:(NSString*)path withTarget:(id)target andAction:(SEL)action withProgress:(id)progress;
@end
