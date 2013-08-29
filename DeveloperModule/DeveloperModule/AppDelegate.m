//
//  AppDelegate.m
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "AppDelegate.h"
#import <sys/utsname.h>

@implementation AppDelegate
@synthesize m_RootNavCtr;

- (void)dealloc
{
    [_window release];
    [m_RootNavCtr release];
//    [location release];
    [super dealloc];
}

//支付宝调用判断设备的方法
- (BOOL)isSingleTask{
	struct utsname name;
	uname(&name);
	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
	if (version < 4.0 || strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0) {
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //百度地图的初始化
//    // 要使用百度地图,请先启动 BaiduMapManager
//    _mapManager = [[BMKMapManager alloc]init];
//    // 如果要关注网络及授权验证事件,请设定 generalDelegate 参数
//    BOOL ret = [_mapManager start:@"4E97BE788681966490F63A939F1D949623B7282B" generalDelegate:nil];
//    if (!ret) {
//        NSLog(@"manager start failed!");
//    }
    
    [[DataCenter shareInstance] initShareSDK];
//    location = [[GetLocationInfo alloc] init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor clearColor];

    UIImageView *loginimg = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    loginimg.image = [UIImage imageNamed:@"bg_index.png"];
    [self.window addSubview:loginimg];
    [loginimg release];
    
    RootNavViewController *navCtr = [[RootNavViewController alloc] init];
    self.m_RootNavCtr = navCtr;
    m_RootNavCtr.navigationBar.barStyle = UIBarStyleBlackOpaque;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    for (UIView *obj in m_RootNavCtr.navigationBar.subviews) {
        NSString *name = [NSString stringWithFormat:@"%s",object_getClassName(obj)];
        NSString *navBackName;
        if (version <6.0) {
            navBackName = @"UINavigationBarBackground";
        }
        else {
            navBackName = @"_UINavigationBarBackground";
        }
        if ([name isEqualToString:navBackName]) {
            UIImageView *barImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            barImageView.image = [[UIImage imageNamed:@"bac-1"] stretchableImageWithLeftCapWidth:2.5 topCapHeight:22];
            [obj addSubview:barImageView];
            [barImageView release];
        }
    }
    if (version < 5.0) {
        
        [m_RootNavCtr.navigationBar setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bac-1"]]];
        //        [m_RootNavCtr.navigationBar setBackgroundImage:[UIImage imageNamed:@"gold_bg_menu.png"]];
        //        [m_RootNavCtr.navigationBar setTintColor:[UIColor colorWithRed:91.0f/255.0f green:157.0f/255.0f blue:196.0f/255.0f alpha:1.0f]];
    }
    
    //[m_RootNavCtr.navigationBar setHidden:YES];
    [navCtr release];
    
    self.window.rootViewController = m_RootNavCtr;
    [self.window makeKeyAndVisible];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"notification"] length] > 0) {
        self.valuePush = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"notification"]];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    application.applicationIconBadgeNumber = 0;
    //判断程序是不是由推送服务完成的
    if (launchOptions) {
        pushLaunch = YES;
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
            if (alert || alert.isVisible) {
                [alert dismissWithClickedButtonIndex:0 animated:NO];
            }
            alert = [[CAlertView alloc] initWithTitle:@"推送消息"
                                               message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                              delegate:self
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@"查看",nil];
            //            recUrl = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"url"]];
            if (recDic != userInfo) {
                [recDic release];
                recDic = [userInfo retain];
            }
            
            [alert show];
            [alert release];
        }
    }
    else {
//        [location StartLocation];
    }
    
    /*
	 *单任务handleURL处理
	 */
	if ([self isSingleTask]) {
		NSURL *url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
		
		if (nil != url) {
			[self parseURL:url application:application];
		}
	}
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    if ([self.payKind isEqualToString:@"TX"]) {
//        [Tenpay handlePayCallBack:url];
//    } else if ([self.payKind isEqualToString:@"ZFB"]){
//        [self parseURL:url application:application];
//    }
//    else {
//        return [ShareSDK handleOpenURL:url wxDelegate:self];
//    }
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}


- (void)parseURL:(NSURL *)url application:(UIApplication *)application {
//	AlixPay *alixpay = [AlixPay shared];
//	AlixPayResult *result = [alixpay handleOpenURL:url];
//	if (result) {
//		//是否支付成功
//		if (9000 == result.statusCode) {
//			/*
//			 *用公钥验证签名
//			 */
//			id<DataVerifier> verifier = CreateRSADataVerifier([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA public key"]);
//            
//			if ([verifier verifyString:result.resultString withSign:result.signString] && [result.success isEqualToString:@"true"]) {
//				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//																	 message:@"支付成功"
//																	delegate:nil
//														   cancelButtonTitle:@"确定"
//														   otherButtonTitles:nil];
//				[alertView show];
//				[alertView release];
//                //付款成功，调用积分接口
//                [[DataCenter shareInstance] getConsumeIntergral];
//                self.payMoney = [NSString stringWithFormat:@"2"];
//                
//			} else {
//                //验签错误
//				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//																	 message:@"签名错误"
//																	delegate:nil
//														   cancelButtonTitle:@"确定"
//														   otherButtonTitles:nil];
//				[alertView show];
//				[alertView release];
//			}
//		}
//		//如果支付失败,可以通过result.statusCode查询错误码
//		else {
//            
//			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//																 message:result.statusMessage
//																delegate:nil
//													   cancelButtonTitle:@"确定"
//													   otherButtonTitles:nil];
//			[alertView show];
//			[alertView release];
//		}
//		
//	}
}

#pragma mark -
#pragma mark tenpay delegate
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* token = [NSString stringWithFormat:@"%@",deviceToken];
    NSLog(@"%@",deviceToken);
    //把deviceToken发送到我们的推送服务器
    NSRange range = NSMakeRange(1, [token length]-2);
    NSString *subString = [token substringWithRange:range];   //获取到的token 发送到服务器
}

//3.接收注册推送通知功能时出现的错误，并做相关处理:
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    //NSLog(@"apns -> 注册推送功能时发生错误， 错误信息:\n %@", err);
}

//4. 接收到推送消息，解析处理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;
    if (recDic != userInfo) {
        [recDic release];
        recDic = [userInfo retain];
    }
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
        alert = [[CAlertView alloc] initWithTitle:@"推送消息"
                                           message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                          delegate:self
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:@"查看",nil];
        recDic = [[NSDictionary alloc] initWithDictionary:userInfo];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        m_NewsDetailCtr = [[NewsDetailViewController alloc] init];
//        NewsData *data = [[NewsData alloc] init];
//        data.title = [recDic valueForKey:@"title"];
//        data.newid = [recDic valueForKey:@"newid"];
//        
//        NSLog(@"%@",[recDic valueForKey:@"newid"]);
//        
//        m_NewsDetailCtr.newsData = data;
//        [data release];
//        [m_RootNavCtr pushViewController:m_NewsDetailCtr animated:YES];
//        [m_NewsDetailCtr release];
//        
//        m_NewsDetailCtr.title = @"资讯";
//        [[DataCenter shareInstance] newsClicked:data.newid];
//        [m_NewsDetailCtr loadNewsWithString:[NSString stringWithFormat:@"%@%@",NEWS_BASE_URL,[recDic valueForKey:@"newid"]]];
//        //        [recDic release];
//    }
//    if (pushLaunch) {
//        [location StartLocation];
//    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([sourceApplication isEqualToString:@"com.alipay.safepayclient"]) {
        [self parseURL:url application:application];
        return YES;
    }
    
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation wxDelegate:self];
}

@end
