//
//  Utils.m
//  eCity
//
//  Created by MeGoo on 11/26/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//

#import "Utils.h"
#import <dlfcn.h>
#import <QuartzCore/QuartzCore.h>
#import "sys/utsname.h"

@implementation Utils

+ (NSMutableDictionary*)getPropertyWithType:(Class)objClass withSuper:(BOOL)getSuper {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(objClass, &outCount);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:outCount];
    NSMutableArray *typeArray = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if([propertyName isEqualToString:@"primaryKey"]||[propertyName isEqualToString:@"rowid"])
        {
            continue;
        }
        [propertyArray addObject:propertyName];
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         c char
         i int
         l long
         s short
         d double
         f float
         @ id //指针 对象
         ...  BOOL 获取到的表示 方式是 char
         .... ^i 表示  int*  一般都不会用到
         */
        
        if ([propertyType hasPrefix:@"T@"]) {
            [typeArray addObject:[propertyType substringWithRange:NSMakeRange(3, [propertyType rangeOfString:@","].location-4)]];
        }
        else if ([propertyType hasPrefix:@"Ti"])
        {
            [typeArray addObject:@"int"];
        }
        else if ([propertyType hasPrefix:@"Tf"])
        {
            [typeArray addObject:@"float"];
        }
        else if([propertyType hasPrefix:@"Td"]) {
            [typeArray addObject:@"double"];
        }
        else if([propertyType hasPrefix:@"Tl"])
        {
            [typeArray addObject:@"long"];
        }
        else if ([propertyType hasPrefix:@"Tc"]) {
            [typeArray addObject:@"char"];
        }
        else if([propertyType hasPrefix:@"Ts"])
        {
            [typeArray addObject:@"short"];
        }
    }
    free(properties);
    id obj = [[objClass alloc] init];
    if(getSuper && [obj superclass] != [NSObject class])
    {
        NSMutableDictionary *tmpDic = [self getPropertyWithType:[obj superclass]withSuper:getSuper];
        [propertyArray addObjectsFromArray:[tmpDic objectForKey:@"name"]];
        [typeArray addObjectsFromArray:[tmpDic objectForKey:@"type"]];
        
    }
    [obj release];
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:propertyArray,@"name",typeArray,@"type",nil];
}

+ (NSMutableDictionary*)getPropertyWithType:(Class)objClass {
    return [self getPropertyWithType:objClass withSuper:NO];
}

+ (NSMutableArray*)getClassProperty:(Class)objClass withSuper:(BOOL)getSuper {
    return [[self getPropertyWithType:objClass withSuper:getSuper] objectForKey:@"name"];
}

+ (NSMutableArray*)getClassProperty:(Class)class {
    return [[self getPropertyWithType:class] objectForKey:@"name"];
//    unsigned int outCount;
//    objc_property_t *properties = class_copyPropertyList(class, &outCount);
//    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:outCount];
//    for (int i = 0; i < outCount ; i++)
//    {
//        const char* propertyName = property_getName(properties[i]);
//        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
//    }
//    free(properties);
//    return propertyArray;
}

+ (NSMutableArray*)getPropertyArray:(id)obj {
    Class class = [obj class];
    return [self getClassProperty:class];
}

+ (NSMutableDictionary*)getPropertyDic:(id)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *propertyArray = [Utils getPropertyArray:obj];
    for (NSString *name in propertyArray) {
        id value = [obj valueForKey:name];
        if (!value) {
            continue;
        }
        if (![value isKindOfClass:[NSString class]]&&![value isKindOfClass:[NSNumber class]]&&![value isKindOfClass:[NSArray class]]) {
            value = [Utils getPropertyDic:value];
        }
        [dic setObject:value forKey:name];
    }
    return dic;
}

+ (NSString*)getStringFromDic:(NSDictionary*)dic {
    if ([dic count]==0) {
        return nil;
    }
    return [Utils jsonFromDic:dic];;
}

+ (NSString*)getJsonFromObj:(id)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *propertyArray = [Utils getPropertyArray:obj];
    for (NSString *name in propertyArray) {
        id value = [obj valueForKey:name];
        if (!value) {
            continue;
        }
        if (![value isKindOfClass:[NSString class]]&&![value isKindOfClass:[NSNumber class]]&&![value isKindOfClass:[NSArray class]]) {
            value = [Utils getJsonFromObj:value];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (id arrayObj in (NSArray*)value) {
                if ([arrayObj isKindOfClass:[NSString class]]) {
                    [array addObject:arrayObj];
                } else {
                    [array addObject:[self getJsonFromObj:arrayObj]];
                }
                
            }
            [dic setObject:array forKey:name];
            [array release];
            continue;
        }
        [dic setObject:value forKey:name];
    }
    return [Utils getStringFromDic:dic];
}


+ (void)setProperty:(id)obj withDic:(NSDictionary*)dic {
    NSArray *propertyArray = [Utils getPropertyArray:obj];
    for (NSString *propertyName in propertyArray) {
        id value = [dic objectForKey:propertyName];
        [obj setValue:value forKey:propertyName];
    }
}

typedef NSDictionary *(*PMobileInstallationLookup)(NSDictionary *params, id callback_unknown_usage);
+ (NSDictionary*)getInstalledApps {
    void *lib = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_LAZY);
	if (lib)
	{
		PMobileInstallationLookup pMobileInstallationLookup = (PMobileInstallationLookup)dlsym(lib, "MobileInstallationLookup");
		if (pMobileInstallationLookup)
		{
            //需要获取的应用id列表
			NSArray *wanted = nil;
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"User", @"ApplicationType", wanted, @"BundleIDs",nil];
			NSDictionary *dict = pMobileInstallationLookup(params, NULL);
#ifdef DEBUG
//			NSLog(@"%@", dict);
#endif
			return dict;
		}
	}
	return nil;
}

typedef int (*PMobileInstallationInstall)(NSString *path, NSDictionary *dict, void *na, NSString *path2_equal_path_maybe_no_use);
+ (InstallResult)installAppWithPath:(NSString*)path {
    void *lib = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_LAZY);
	if (lib)
	{
		PMobileInstallationInstall pMobileInstallationInstall = (PMobileInstallationInstall)dlsym(lib, "MobileInstallationInstall");
		if (pMobileInstallationInstall)
		{
			NSString *name = [@"Install_" stringByAppendingString:path.lastPathComponent];
			NSString* temp = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
			if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:temp error:nil])
                return InstallResultFileNotFound;
			NSDictionary *typeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"User",@"ApplicationType",nil];
			int ret = (InstallResult)pMobileInstallationInstall(temp, typeDic, 0, path);
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
            if (ret != 0) {
                NSLog(@"IPA 安装失败。\n\n错误代码：%#08X",ret);
            }
			return ret;
		}
	}
    NSLog(@"私有API未找到");
    return InstallResultNoFunction;
}

+ (BOOL)isFileExists:(NSString*)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


+ (void)copyFiletoDst:(NSString*)fileName withFolder:(NSString*)folder {
    NSString *srcPath = [self getSrcFilePath:fileName];
	NSString *dstPath = [self getDstFilePath:fileName withFolder:folder];
    if (srcPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:dstPath]) {
            if (![[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil]) {
                NSLog(@"copy file error!");
            }
        }
    }
}

+ (void)deleteFileFromDst:(NSString*)fileName withFolder:(NSString*)folder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager removeItemAtPath:[self getDstFilePath:fileName withFolder:folder] error:nil])
    {
        NSLog(@"delete file error!");
    }
}

+ (NSString*)getSrcFilePath:(NSString *)fileName {
    NSString *prefixName = [fileName substringToIndex:[fileName rangeOfString:@"."].location];
    NSString *subfixName = [fileName substringFromIndex:[fileName rangeOfString:@"."].location+1];
    NSString *str = [[NSBundle mainBundle] pathForResource:prefixName ofType:subfixName];
    return str;
}

+ (NSString*)getDstFilePath:(NSString *)fileName withFolder:(NSString*)folder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取沙盒文件路径，不存在的话创建该路径
	NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:folder];
	if (![fileManager fileExistsAtPath:filePath]) {
		if (![fileManager createDirectoryAtPath:filePath
					withIntermediateDirectories:YES
									 attributes:nil
										  error:nil]) {
			NSLog(@"file directory create failed!");
		}
	}
	return [filePath stringByAppendingPathComponent:fileName];
}


//拷贝应用程序文件
+ (void)copyPlistToDst:(NSString *)fileName
{
	NSString *srcPath = [self getSrcPlistPath:fileName];
	
	NSString *dstPath = [self getDstPlistPath:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dstPath]&&srcPath) {
        if (![[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil]) {
            NSLog(@"copy plist error!");
        }
    }
}


//获取文件在应用程序里的路径
+ (NSString *)getSrcPlistPath:(NSString *)fileName
{
	return [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
}


//获取文件在沙盒里的路径
+ (NSString *)getDstPlistPath:(NSString *)fileName
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
    //获取沙盒plist路径，不存在的话创建该路径
	NSString *plistPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Plist"];
	if (![fileManager fileExistsAtPath:plistPath]) {
		if (![fileManager createDirectoryAtPath:plistPath
					withIntermediateDirectories:YES
									 attributes:nil
										  error:nil]) {
			NSLog(@"plist directory create failed!");
		}
	}
	NSString *withFileType = [fileName stringByAppendingString:@".plist"];
	
	return [plistPath stringByAppendingPathComponent:withFileType];
	
}

+ (void)ShowMessage:(NSString *)text onView:(UIView *)view withTime:(NSTimeInterval)duration
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont systemFontOfSize:13];
	label.text = text;
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentCenter;
	[view addSubview:label];
	
	CGRect frame2;
	CGRect frame = view.frame;
	frame2.size.width = frame.size.width * 3 / 4;
	frame2.size.height = 30 + [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(frame2.size.width, 1000) lineBreakMode:label.lineBreakMode].height;
	frame2.origin.x = (frame.size.width - frame2.size.width) / 2;
	frame2.origin.y = (frame.size.height - frame2.size.height) / 2;
	label.frame = frame2;
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
	CALayer *layer = label.layer;
	layer.cornerRadius = 8;
	layer.masksToBounds = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:duration];
	[UIView setAnimationDuration:1.5];
	[UIView setAnimationDelegate:label];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	label.alpha = 0;
	[UIView commitAnimations];
}

+ (void)ShowMessage:(NSString *)text onStatusWithTime:(NSTimeInterval)duration {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm"];
    NSDate *date = [NSDate date];
    text = [format stringFromDate:date];
    [format release];
    UIWindow *win = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    [win setWindowLevel:UIWindowLevelStatusBar + 1];
    UILabel *lastTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    lastTime.backgroundColor = [UIColor blackColor];
    lastTime.textColor = [UIColor whiteColor];
    lastTime.text =[NSString stringWithFormat:@"最后更新:  今天 %@",text];
    [lastTime setFont:[UIFont boldSystemFontOfSize:11.0f]];
    if (kISIOS6) {
        lastTime.textAlignment = NSTextAlignmentCenter;
    } else {
        lastTime.textAlignment = UITextAlignmentCenter;
    }
    [win addSubview:lastTime];
    [lastTime release];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window performSelector:@selector(makeKeyAndVisible) withObject:nil afterDelay:duration];
    [win performSelector:@selector(release) withObject:nil afterDelay:duration];
    [win makeKeyAndVisible];
}

#pragma mark 手机信息
/**
 获取系统中原始设备信息
 @returns 返回设备原始信息
 */
- (NSString *) platformInfo
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

//获取手机型号
+ (NSString *) platformInfoMation
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);

    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad-4G (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad-4G (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad-4G (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini-1G (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini-1G (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini-1G (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+ (NSString*)stringWithDate:(NSDate*)date andFormat:(NSString*)dateFormat {
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormat];
    NSString* datestr = [formatter stringFromDate:date];
    [formatter release];
    return datestr;
    
}

+ (NSDate*)dateWithString:(NSString*)dateStr andFormat:(NSString*)dateFormat {
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormat];
    NSDate* date = [formatter dateFromString:dateStr];
    [formatter release];
    return date;
}

+ (NSString *)getWeek:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter release];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    [calendar release];
    int week = [comps weekday];
    switch (week) {
        case 1:
            return @"星期天";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
        default:
            return @"星期天";
            break;
    }
}

+ (NSString*)jsonFromDic:(NSDictionary*)dic {
    SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
	NSString * jsonString = [OderJsonwriter stringWithObject:dic];
	[OderJsonwriter release];
    return jsonString;
}

+ (NSDictionary*)dicFromJson:(NSString*)string {
    SBJsonParser * resultParser = [[SBJsonParser alloc] init];
    NSDictionary * jsonQuery = [resultParser objectWithString:string];
    [resultParser release];
    return jsonQuery;
}

+ (float)getSystemVersion {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    return version;
}

+ (BOOL)fileIsImage:(NSString*)fileName {
    if ([fileName hasSuffix:@"jpg"]||[fileName hasSuffix:@"png"]||[fileName hasSuffix:@"jpeg"]||[fileName hasSuffix:@"gif"]||[fileName hasSuffix:@"bmp"]) {
        return YES;
    }
    return NO;
}

+ (NSString *) returnKeyId
{
    return @"0d4e79ac5e96e2b3";
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params
{
	NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
	if (params) {
		[paramsDic setValuesForKeysWithDictionary:params];
	}
	
	NSMutableString *signString = [NSMutableString stringWithString:@"8208541570"];
	NSMutableString *paramsString = [NSMutableString stringWithFormat:@"appkey=%@",@"8208541570"];
	NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
	for (NSString *key in sortedKeys) {
		[signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
		[paramsString appendFormat:@"&%@=%@", key, [paramsDic objectForKey:key]];
	}
	[signString appendString:@"971693e91dd24014a0d3779ecba8729b"];
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	NSData *stringBytes = [signString dataUsingEncoding: NSUTF8StringEncoding];
	if (CC_SHA1([stringBytes bytes], [stringBytes length], digest)) {
		/* SHA-1 hash has been calculated and stored in 'digest'. */
		NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
		for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
			unsigned char aChar = digest[i];
			[digestString appendFormat:@"%02X", aChar];
		}
		[paramsString appendFormat:@"&sign=%@", [digestString uppercaseString]];
		return [NSString stringWithFormat:@"%@://%@%@?%@", [parsedURL scheme], [parsedURL host], [parsedURL path], [paramsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	} else {
		return nil;
	}
}

+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
		
		if ([elements count] <= 1) {
			return nil;
		}
		
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

+ (UIImage *)addTextIntoUIImageView:(NSString *)text
{
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"%.2f,%.2f",size.width,size.height);
    
    // 初始化按钮
    UIImageView *button = [[UIImageView alloc] init];
    // 设置尺寸
    button.frame = CGRectMake(75, 100, size.width/2, 31);
    
    // 加载图片
    UIImage *image = [UIImage imageNamed:@"left"];
    
    image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    // 设置背景图片
    [button setImage:image];
    
    UIImageView *rButton = [[UIImageView alloc] init];
    
    rButton.frame = CGRectMake(75, 250, size.width/2, 31);
    
    // 加载图片
    UIImage *rImage = [UIImage imageNamed:@"right"];
    
    rImage = [rImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    [rButton setImage:rImage];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 400, size.width, 31)];
    [img setImage:[Utils addTwoImageToOne:button.image twoImage:rButton.image withWidth:size.width]];
    
    UIImage *txtImage = [Utils addText:img.image text:text withSize:CGSizeMake(size.width,31)];
    
    [img setImage:txtImage];
    [button release];
    [rButton release];
    return img.image;
}


/**
 加文字水印
 @param img 需要加文字的图片
 @param text1 文字描述
 @returns 加好文字的图片
 */
+ (UIImage *)addText:(UIImage *)img text:(NSString *)text1 withSize:(CGSize)size
{
    //get image width and height
    int w = img.size.width + 7;
    int h = img.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    UIGraphicsPushContext(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
    char* text = (char *)[text1 cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *strResult = [[NSString alloc] initWithCString:text encoding:NSUTF8StringEncoding];
    
    CGContextTranslateCTM(context, 0, h);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    [strResult drawAtPoint:CGPointMake(img.size.width/2 - size.width/2 + 10 , 3) withFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    UIGraphicsPopContext();
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}


/**
	两张图片合成一张图片
	@param oneImg 第一张图片
	@param twoImg 第二张图片
	@param  width 合成后图片的宽度
	@returns 返回合成后的UIImage
 */
+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg withWidth:(CGFloat) width
{
    UIGraphicsBeginImageContext(CGSizeMake(width, 31));
    
    [oneImg drawInRect:CGRectMake(0, 0, width/2, oneImg.size.height/2)];
    [twoImg drawInRect:CGRectMake(width/2, 0, width/2, oneImg.size.height/2)];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImg;
}

@end


@implementation NSString (md5)
-(NSString *) md5HexDigest
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (NSString *)urlEncodedString
{
    NSString * encodedString = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
}

- (NSString *)urlDecodedString
{
    NSString * decodedString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; ;
    return decodedString;
}

- (NSString *)stringRemoveWhiteAndEnter {
    NSString *str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return str;
}

- (NSString *)stringByDecodingXMLEntities {
    
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            return result;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            if (gotNumber) {
                [result appendFormat:@"%C", (unsigned short)charCode];
                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
            }
        }
        else {
            NSString *amp;
            [scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
            [result appendString:amp];
        }
    }
    while (![scanner isAtEnd]);
    return result;
}

@end

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UIDevice(Private)

- (NSString *) macaddress;

@end

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *) uniqueDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash md5HexDigest];
    
    return uniqueIdentifier;
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress md5HexDigest];
    
    return uniqueIdentifier;
}

@end

@implementation NSDate (dateStr)

//@param   date            用于转换的时间

//@param    formatString    时间格式(yyyy-MM-dd HH:mm:ss)

//@return   NSString        返回字字符如（2012－8－8 11:11:11）

+ (NSString *)getDateStringWithDate:(NSDate *)date

                         DateFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:formatString];
    
    NSString *dateString = [dateFormat stringFromDate:date];
    
    NSLog(@"date: %@", dateString);
    
    [dateFormat release];
    
    return dateString;
}

@end

