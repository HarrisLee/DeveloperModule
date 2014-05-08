//
//  DataCenter.m
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "DataCenter.h"

#define ONLINE_TIME         600

static DataCenter *m_DataCenter = nil;
@implementation DataCenter
@synthesize configDictionary;
@synthesize errorDictionary;
@synthesize userInfo;
@synthesize localInfo;
@synthesize city;

+(DataCenter*)shareInstance {
    @synchronized(self)
	{
		if (m_DataCenter == nil)
		{
			m_DataCenter = [[DataCenter alloc] init];
		}
	}
	return m_DataCenter;
}

- (id)init {
    self = [super init];
    if (self) {

        [Utils copyPlistToDst:@"Config"];
        NSDictionary *tmpdic = [[NSDictionary alloc] initWithContentsOfFile:[Utils getDstPlistPath:@"Config"]];
        self.configDictionary = tmpdic;
        [tmpdic release];
        
        tmpdic = [[NSDictionary alloc] initWithContentsOfFile:[Utils getSrcPlistPath:@"errorCode"]];
        self.errorDictionary = tmpdic;
        [tmpdic release];
    }
    return self;
}

//获取大众点评Key
- (NSString *)getTravelKey
{
    return @"8208541570";
}

//获取大众点评sign
- (NSString *)getTravelSign
{
    return @"81DD978FAC02FDAC807AB760177272798BE194DE";
}

- (void)initShareSDK {
    [ShareSDK registerApp:@"3f520f7ff4f"];
    [self initializePlat];
}

- (void)initializePlat {
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"3427592927" appSecret:@"edfa0e3fae214603215a380fb48f4f8c"
                             redirectUri:@"https://api.weibo.com/oauth2/default.html"];
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"801363449" appSecret:@"574bb95a02e77e9a79687be759d0eb19"
                                redirectUri:@"http://www.izs.cn/"];
    
    [ShareSDK connectWeChatWithAppId:@"wxe06942cabe91a50d"
                           wechatCls:[WXApi class]];
    [ShareSDK convertUrlEnabled:NO];
    [ShareSDK setStatPolicy:SSCStatPolicyLimitSize];
}

- (void)shareContent:(id)content withSender:(id)sender
{
    [self shareContent:content title:nil url:nil image:nil withSender:sender];
}

- (void)shareContent:(NSString*)content title:(NSString*)title url:(NSString*)url image:(NSString*)imageUrl withSender:(id)sender{
    id<ISSContainer> container = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        container = [ShareSDK container];
        [container setIPadContainerWithView:sender
                                arrowDirect:UIPopoverArrowDirectionDown];
    }
    UIImage *imageData = [[HttpRequestCenter shareInstance] getImageWithUrl:imageUrl];
    if (!imageData) {
        return;
    }
    id<ISSCAttachment>image = [ShareSDK pngImageWithImage:imageData];
    //构造分享内容
    id<ISSContent>publishContent=[ShareSDK content:content
                                    defaultContent:@"项目名称"
                                             image:image
                                             title:title
                                               url:url
                                       description:@"项目名称内容分享"
                                         mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSShareOptions>shareOptions=[ShareSDK defaultShareOptionsWithTitle:@"内容分享"
                                                           oneKeyShareList:nil qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES wxTimelineButtonHidden:YES showKeyboardOnAppear:YES
                                                         shareViewDelegate:self friendsViewDelegate:self
                                                     picViewerViewDelegate:nil];
    
    //    id<ISSShareOptions>shareOptions = [ShareSDK simpleShareOptionsWithTitle:@"内容分享" shareViewDelegate:nil];
    id<ISSAuthOptions>authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                        allowCallback:NO
                                                        authViewStyle:SSAuthViewStyleModal
                                                         viewDelegate:nil
                                              authManagerViewDelegate:nil];
    
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeSMS,nil];
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                      authOptions :authOptions
                      shareOptions:shareOptions
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo>
                                     statusInfo,id<ICMErrorInfo>error,BOOL end){
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    CAlertView *alert = [[CAlertView alloc] initWithTitle:@"分享失败"
                                                                                  message:[error errorDescription]
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"确定"
                                                                        otherButtonTitles:nil];
                                    [alert show];
                                    [alert release];
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode],[error errorDescription]);
                                }
                            }
     ];
}

- (id<ISSContent>)view:(UIViewController *)viewController
    willPublishContent:(id<ISSContent>)content {
    if (willShareType == ShareTypeSinaWeibo || willShareType == ShareTypeTencentWeibo) {
        [content setContent:[NSString stringWithFormat:@"%@%@",content.content,content.url]];
    }
    if (willShareType == ShareTypeSinaWeibo) {
        [content setContent:[NSString stringWithFormat:@"%@ @项目名称",content.content]];
    }
    return content;
}

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType {
    willShareType = shareType;
}

+ (NSString *)saveImageFile:(UIImage*)image
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    NSData *imagedata=UIImagePNGRepresentation(image);
    //JEPG格式
    //NSData *imagedata=UIImageJEPGRepresentation(m_imgFore,1.0);
    NSString *tempDirectory=NSTemporaryDirectory();
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%d.png",[formater stringFromDate:[NSDate date]],arc4random()%1000];
    NSString *savedImagePath=[tempDirectory stringByAppendingPathComponent:fileName];
    [imagedata writeToFile:savedImagePath atomically:YES];
    
    [formater release];
    return savedImagePath;
}

- (void)dealloc {
    [configDictionary release];
    [m_DataCenter release];
    [userInfo release];
    [city release];
    [super dealloc];
}

@end
