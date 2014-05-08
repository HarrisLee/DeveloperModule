//
//  HttpRequestCenter.m
//  DeveloperModule
//
//  Created by Melo on 13-8-15.
//  Copyright (c) 2013年 Melo. All rights reserved.
//

#import "HttpRequestCenter.h"

static HttpRequestCenter *m_RequestCenter = nil;

@implementation HttpRequestCenter

+(HttpRequestCenter*)shareInstance {
    @synchronized(self)
	{
		if (m_RequestCenter == nil)
		{
			m_RequestCenter = [[HttpRequestCenter alloc] init];
		}
	}
	
	return m_RequestCenter;
}

- (id)init {
    self = [super init];
    if (self) {
        downloadCache = [[ASIDownloadCache alloc] init];
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        //设置缓存存放路径
        [downloadCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"Resource"]];
        //设置缓存策略
        [downloadCache setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
        //设置是否按服务器在Header里指定的是否可被缓存或过期策略进行缓存
        [downloadCache setShouldRespectCacheControlHeaders:NO];
        
        //初始化请求url字典
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ReqUrlDefine" ofType:@"plist"];
        urlDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        //初始化返回结构体名称字典，不同请求类型对应的结构体名称
        plistPath = [[NSBundle mainBundle] pathForResource:@"RespNameDefine" ofType:@"plist"];
        respNameDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        plistPath = [[NSBundle mainBundle] pathForResource:@"ErrorCode" ofType:@"plist"];
        errorCodeDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        //初始化请求队列
        m_Queue = [[ASINetworkQueue alloc] init];
        m_Queue.maxConcurrentOperationCount = 5;
        [m_Queue setShouldCancelAllRequestsOnFailure:NO];
        [m_Queue go];
        
        //初始化下载队列
        m_DownloadQueue = [[ASINetworkQueue alloc] init];
        m_DownloadQueue.maxConcurrentOperationCount = 10;
        [m_DownloadQueue setShouldCancelAllRequestsOnFailure:NO];
        [m_DownloadQueue go];
    }
    return self;
}

//根据时间显示蒙板
- (void)showMaskWithTimer:(NSTimeInterval)time onView:(UIView*)view{
    //如果蒙板存在，重设移除蒙版时间
    if (maskView && maskView.superview) {
        [self setMaskTimer:time];
        return;
    }
    if (!view) {
        view = [[UIApplication sharedApplication].delegate window];
    }
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = maskView.center;
    [activityView startAnimating];
    [maskView addSubview:activityView];
    [activityView release];

    [view addSubview:maskView];
    [maskView release];
    
    [self setMaskTimer:time];
}

//设置移除蒙板timer
- (void)setMaskTimer:(NSTimeInterval)time  {
    if ([maskTimer isValid]) {
        [maskTimer invalidate];
        maskTimer = nil;
    }
    maskTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(removeMask) userInfo:nil repeats:NO];
}

//移除蒙板
- (void)removeMask {
    if ([maskTimer isValid]) {
        [maskTimer invalidate];
        maskTimer = nil;
    }
    if (maskView && maskView.superview) {
        [maskView removeFromSuperview];
        maskView = nil;
    }
}


//请求时是否显示蒙板
- (void)requestWithBody:(ReqBody*)reqBody andReqType:(NSString*)reqType withTarget:(id)target andAction:(SEL)action withMask:(BOOL)mask {
    if (mask) {
        [self showMaskWithTimer:30 onView:[[UIApplication sharedApplication].delegate window]];
    }
    
    [self requestWithBody:reqBody andReqType:reqType withTarget:target andAction:action];
}

//根据请求体请求类型以及目标与执行函数来进行请求
- (void)requestWithBody:(ReqBody*)reqBody andReqType:(NSString*)reqType withTarget:(id)target andAction:(SEL)action {
    
    //根据请求类型创建请求URL
    NSString *reqStr = [NSString stringWithFormat:@"%@%@",[[DataCenter shareInstance].configDictionary objectForKey:@"ip地址"],[urlDic objectForKey:reqType]];
    //从请求体获取属性组装请求字符串
    NSDictionary *dic = [Utils getPropertyDic:reqBody];
    //对获取到的属性数组进行拼接,组成请求URL
    NSString *paraXML = [NSString stringWithFormat:@"?"];
    for (id keyString in [dic allKeys]) {
        paraXML = [paraXML stringByAppendingFormat:@"%@=%@&",keyString,[dic objectForKey:keyString]];
    }
    //若请求体属性为空则不进行URL拼接.
    if ([paraXML length]>1) {
        reqStr = [NSString stringWithFormat:@"%@%@",reqStr,[paraXML substringToIndex:[paraXML length]-1]];
    }
    
    NSLog(@"RequestUrl:%@",reqStr);
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:reqStr]];
    
    //根据请求的类型确定请求回调的方法
    if (target) {
        NSValue *selValue = [NSValue value:&action withObjCType:@encode(SEL)];
        NSMutableDictionary *aDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:target,@"target",selValue,@"SEL",reqType,@"reqType",reqBody,@"reqBody",nil];
        request.userInfo = aDic;
        [aDic release];
    }
    //从请求体获取属性组装请求字符串
    //NSDictionary *dic = [Utils getPropertyDic:reqBody];
    NSString *str = [Utils getJsonFromObj:reqBody];
    str = [str stringRemoveWhiteAndEnter];
    [request setPostValue:str forKey:@"parameXML"];
    
    [request setDelegate:self];
    [request setDownloadProgressDelegate:target];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [m_Queue addOperation:request];
    [request release];
    
}

- (NSString*)hexStringFromData:(NSData*)data {
    Byte *bytes = (Byte*)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSLog(@"byte:%d",bytes[i]);
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

- (NSData *)dataFromHexString:(NSString*)string {
    NSArray *array = [string componentsSeparatedByString:@" "];
    //    Byte byte[[array count]];
    NSMutableData *byteData = [NSMutableData data];
    
    for (int i = 0; i< [array count]; i++) {
        NSString *obj = [array objectAtIndex:i];
        NSScanner* scanner = [NSScanner scannerWithString:obj];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [byteData appendBytes:&intValue length:1];
    }
    return byteData;
}

//根据请求类型拼接soap字符串
- (NSString*)appendSoapStr:(NSString*)string WithType:(NSString*)type {
    NSMutableString* str = [NSString stringWithFormat:
                            @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                            "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                            "<soap:Body>\n"
                            "<%@>\n"
                            "%@%@%@\n"
                            "</%@>\n"
                            "</soap:Body>\n"
                            "</soap:Envelope>\n",type,string?@"<in0>":@"",string?string:@"",string?@"</in0>":@"",type];
    NSLog(@"ReqStr:%@",str);
	return str;
}

//请求成功返回
- (void)requestDone:(ASIHTTPRequest *)request
{
    [self removeMask];
    NSData *respData = [request responseData];
    NSLog(@"%@",[[[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding] autorelease]);
    //根据类名创建对象
    NSString *respName = [respNameDic objectForKey:[request.userInfo objectForKey:@"reqType"]];
    RespBody *respBody = [[[NSClassFromString(respName) alloc] init] autorelease];
    
    NSError *error = nil;
    
    id respDic = nil;
    if (respData) {
        respDic =[NSJSONSerialization JSONObjectWithData:respData
                                                 options:kNilOptions
                                                   error:&error];
    }
    if (error) {
        NSLog(@"json解析错误:%@",error);
        respBody.jsonMsg = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
        [self callBackWith:request andRespBody:respBody];
        [respBody.jsonMsg release];
        return;
    }
    
    //根据返回数据进行填充返回数据结构体
    if (respDic) {
        [respBody setValue:respDic];
    }
    
    [self callBackWith:request andRespBody:respBody];

}

//请求失败
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    [self removeMask];
    NSError *error = [request error];
    NSLog(@"%@",error);
    NSString *respName = [respNameDic objectForKey:[request.userInfo objectForKey:@"reqType"]];
    RespBody *respBody = [[[NSClassFromString(respName) alloc] init] autorelease];
    if (error) {
        respBody.jsonMsg = error.description;
    }
    else {
        respBody.jsonMsg = @"网络连接错误";
    }
    [self callBackWith:request andRespBody:respBody];

}

- (void)callBackWith:(ASIHTTPRequest*)request andRespBody:(RespBody*)respBody{
//    NSString *errTitle = @"错误";
//    NSString *errMsg = [errorCodeDic objectForKey:respBody.code];
//    if (!errMsg) {
//        errMsg = @"请求失败";
//    }
//    //服务器返回失败，弹出提示，后续根据错误码显示不同提示
//    if (![respBody.code isEqualToString:@"000000"]&&respBody.code!=nil) {
//        [Utils ShowMessage:errMsg onStatusWithTime:2];
//    }
    //判断使用哪种方式进入网络请求，使用相应方式返回数据
    SEL action;
    [(NSValue *)[request.userInfo objectForKey:@"SEL"] getValue:&action];
    id delegate = [request.userInfo objectForKey:@"delegate"];
    if (action) {
        [[request.userInfo objectForKey:@"target"] performSelector:action withObject:respBody];
    }
    else if (delegate && [delegate respondsToSelector:@selector(dataComBack:andReqType:)]){
        [delegate dataComBack:respBody andReqType:[request.userInfo objectForKey:@"ReqType"]];
    }
}

- (UIImage*)getImageWithUrl:(NSString*)imageUrl {
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:imageUrl]];
    [request setRequestMethod:@"GET"];
    [request setShouldContinueWhenAppEntersBackground:YES];
    //当前请求设置使用缓存
    [request setDownloadCache:downloadCache];
    //当前请求设置存储策略，永久保存到本地磁盘
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    //设值缓存30天
    [request setSecondsToCache:60*60*24*30];
    [request setDelegate:self];
    [request startSynchronous];
    return [UIImage imageWithData:request.responseData];
}

//根据url请求图片并缓存
- (void)requestImageWithUrl:(NSString*)imageUrl andImageView:(UIImageView*)imageView{
#ifdef TEST
    [imageView setImage:[UIImage imageNamed:imageUrl]];
#else
//    imageUrl = [imageUrl stringByAppendingFormat:@"&width=%.f",imageView.frame.size.width*2];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:imageUrl]];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:60];
    //当前请求设置使用缓存
    [request setDownloadCache:downloadCache];
    //当前请求设置存储策略，永久保存到本地磁盘
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    //设值缓存30天
    [request setSecondsToCache:60*60*24*30];
    [request setDelegate:self];
    [request setDidStartSelector:@selector(didStartImageRequest:)];
    [request setDidFinishSelector:@selector(didFinishImageRequest:)];
    [request setDidFailSelector:@selector(didFailedImageRequest:)];
    if (imageView) {
        NSDictionary *aDic = [[NSDictionary alloc] initWithObjectsAndKeys:imageView,@"imageView",nil];
        request.userInfo = aDic;
        [aDic release];
    }
    [m_DownloadQueue addOperation:request];
    [request release];
#endif
}

- (void)didStartImageRequest:(ASIHTTPRequest *)request{

}

//请求成功返回处理结果
- (void)didFinishImageRequest:(ASIHTTPRequest *)request{

    if([request responseStatusCode] == 200 || [request responseStatusCode] == 304){
//        if([request didUseCachedResponse]){
//            NSLog(@"从缓存获取");
//        }
//        else {
//            NSLog(@"从网络获取");
//        }
    }
    UIImageView *imageView = [request.userInfo objectForKey:@"imageView"];
    NSData *imageData = [request responseData];
    [imageView imageBack:[UIImage imageWithData:imageData]];
}

- (void)didFailedImageRequest:(ASIHTTPRequest *)request{

}

- (void)downloadFileWithUrl:(NSString*)url andPath:(NSString*)path withTarget:(id)target andAction:(SEL)action withProgress:(id)progress withMask:(BOOL)mask {
    if (mask) {
        [self showMaskWithTimer:30 onView:nil];
    }
    [self downloadFileWithUrl:url andPath:path withTarget:target andAction:action withProgress:progress];
}

- (void)downloadFileWithUrl:(NSString*)url andPath:(NSString*)path withTarget:(id)target andAction:(SEL)action withProgress:(id)progress{
    NSLog(@"download Url:%@",url);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setDownloadDestinationPath:path];
    [request setTemporaryUncompressedDataDownloadPath:NSTemporaryDirectory()];
    [request setDelegate:self];
    if (progress) {
        request.showAccurateProgress = YES;
        [request setDownloadProgressDelegate:progress];
    }
    if (target) {
        NSValue *selValue = [NSValue value:&action withObjCType:@encode(SEL)];
        NSDictionary *aDic = [[NSDictionary alloc] initWithObjectsAndKeys:target,@"target",selValue,@"SEL",path,@"path",nil];
        request.userInfo = aDic;
        [aDic release];
    }
    [request setDidStartSelector:@selector(didStartDownloadRequest:)];
    [request setDidFinishSelector:@selector(didFinishDownloadRequest:)];
    [request setDidFailSelector:@selector(didFailedDownloadRequest:)];
    [m_DownloadQueue addOperation:request];
    [request release];

}

- (void)didStartDownloadRequest:(ASIHTTPRequest *)request{

}

- (void)didFinishDownloadRequest:(ASIHTTPRequest *)request
{
    [self removeMask];
    SEL action;
    [(NSValue *)[request.userInfo objectForKey:@"SEL"] getValue:&action];
    id target = [request.userInfo objectForKey:@"target"];
    if ([target respondsToSelector:action])
    {
        [target performSelector:action withObject:[request.userInfo objectForKey:@"path"]];
    }
}

- (void)didFailedDownloadRequest:(ASIHTTPRequest *)request{
    [self removeMask];
    NSLog(@"%@",request.error);
}


- (void)uploadFileWithUrl:(NSString*)url andPath:(NSString*)path withTarget:(id)target andAction:(SEL)action withProgress:(id)progress {
    [self showMaskWithTimer:30 onView:[[UIApplication sharedApplication].delegate window]];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setRequestMethod:@"POST"];
    NSArray *tmpArr = [path componentsSeparatedByString:@"/"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [request appendPostData:data];
    //    [request setData:data forKey:@"image"];
    //    模拟表单将图片数据以二进制的格式发送出去
    //    [request setFile:path forKey:[tmpArr lastObject]];
    //    [request setFile:path withFileName:[path lastPathComponent] andContentType:@"" forKey:@""];  //废弃
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    if (progress) {
        request.showAccurateProgress = YES;
        [request setDownloadProgressDelegate:progress];
    }
    if (target) {
        NSValue *selValue = [NSValue value:&action withObjCType:@encode(SEL)];
        NSDictionary *aDic = [[NSDictionary alloc] initWithObjectsAndKeys:target,@"target",selValue,@"SEL",path,@"path",nil];
        request.userInfo = aDic;
        [aDic release];
    }
    [request setDidStartSelector:@selector(didStartUploadRequest:)];
    [request setDidFinishSelector:@selector(didFinishUploadRequest:)];
    [request setDidFailSelector:@selector(didFailedUploadRequest:)];
    [m_DownloadQueue addOperation:request];
    [request release];
}

- (void)didStartUploadRequest:(ASIFormDataRequest*)request {
    
}

- (void)didFinishUploadRequest:(ASIFormDataRequest *)request{
    [self removeMask];
    //    NSLog(@"%@",[request responseString]);
    SEL action;
    [(NSValue *)[request.userInfo objectForKey:@"SEL"] getValue:&action];
    id target = [request.userInfo objectForKey:@"target"];
    if ([target respondsToSelector:action]) {
        [target performSelector:action withObject:[request responseString]];
    }
}

- (void)didFailedUploadRequest:(ASIFormDataRequest *)request{
    [self removeMask];
    NSLog(@"%@",request.error);
    alertMessage(@"可能由于网络原因，上传图片失败，请稍后再试！");
}

- (void)dealloc {
    [urlDic release];
    [respNameDic release];
    [errorCodeDic release];
    [m_Queue release];
    [m_DownloadQueue release];
    [super dealloc];
}

@end
