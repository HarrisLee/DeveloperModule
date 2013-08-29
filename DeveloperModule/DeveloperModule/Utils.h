//
//  Utils.h
//  eCity
//
//  Created by xuchuanyong on 11/26/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//
//工具类，常用方法定义
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "SBJSON.h"

#ifdef __cplusplus
#define EXTERN_C extern "C"
#else
#define EXTERN_C extern
#endif

#define usualFormat  @"yyyy-MM-dd HH:mm:ss"

// 安装结果
typedef enum
{
	InstallResultOK = 0,				// 安装成功
	InstallResultFail = -1,				// 安装失败
	InstallResultNoFunction = 0xBEFC,	// 私有 API 未找到
	InstallResultFileNotFound = 0xBFEC,	// 拷贝 IPA 错误
}
InstallResult;

@interface Utils : NSObject

+ (NSMutableDictionary*)getPropertyWithType:(Class)objClass withSuper:(BOOL)getSuper;

+ (NSMutableDictionary*)getPropertyWithType:(Class)objClass;

+ (NSMutableArray*)getClassProperty:(Class)objClass withSuper:(BOOL)getSuper;

//获取类的属性列表
+ (NSMutableArray*)getClassProperty:(Class)objClass;

//获取对象的属性列表
+ (NSMutableArray*)getPropertyArray:(id)obj;

//获取类的属性与值的字典
+ (NSMutableDictionary*)getPropertyDic:(id)obj;

//将字典转换为json字符串
+ (NSString*)getStringFromDic:(NSDictionary*)dic;

//根据字典对对象设值
+ (void)setProperty:(id)obj withDic:(NSDictionary*)dic;

//获取已安装的应用信息
+ (NSDictionary*)getInstalledApps;

//根据ipa包的路径安装应用
+ (InstallResult)installAppWithPath:(NSString*)fromPath;

+ (BOOL)isFileExists:(NSString*)filePath;
+ (void)copyFiletoDst:(NSString*)fileName withFolder:(NSString*)folder;
+ (void)deleteFileFromDst:(NSString*)fileName withFolder:(NSString*)folder;
+ (NSString*)getSrcFilePath:(NSString *)fileName;
+ (NSString*)getDstFilePath:(NSString *)fileName withFolder:(NSString*)folder;

//获取plist文件的应用程序路径
+ (NSString *)getSrcPlistPath:(NSString *)fileName;

//获取plist文件的沙盒路径
+ (NSString *)getDstPlistPath:(NSString *)fileName;

//将plist文件从应用程序拷贝到沙盒
+ (void)copyPlistToDst:(NSString *)fileName;

//在屏幕上显示消息
+ (void)ShowMessage:(NSString *)text onView:(UIView *)view withTime:(NSTimeInterval)duration;

+ (void)ShowMessage:(NSString *)text onStatusWithTime:(NSTimeInterval)duration;

//获取手机唯一标识
+ (NSString*)getIdentifier;

+ (NSString*)stringWithDate:(NSDate*)date andFormat:(NSString*)dateFormat;

+ (NSDate*)dateWithString:(NSString*)dateStr andFormat:(NSString*)dateFormat;

+ (NSString*)jsonFromDic:(NSDictionary*)dic;

+ (NSString*)getJsonFromObj:(id)obj;

+ (NSDictionary*)dicFromJson:(NSString*)string;

+ (float)getSystemVersion;

+ (BOOL)fileIsImage:(NSString*)fileName;

+ (NSString *) returnKeyId;

//大众点评接口请求格式化
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;

+ (UIImage *)addTextIntoUIImageView:(NSString *)text;

+ (UIImage *)addText:(UIImage *)img text:(NSString *)text1 withSize:(CGSize)size;

+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg withWidth:(CGFloat) width;

@end

#import <CommonCrypto/CommonDigest.h>

@interface NSString (md5)
//md5加密
-(NSString *) md5HexDigest;

- (NSString *)urlEncodedString;
- (NSString *)urlDecodedString;
- (NSString *)stringByDecodingXMLEntities;
- (NSString *)stringRemoveWhiteAndEnter;
@end

@interface UIDevice (IdentifierAddition)

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

- (NSString *) uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

- (NSString *) uniqueGlobalDeviceIdentifier;

@end


@interface NSDate (dateStr)

//@param   date            用于转换的时间

//@param    formatString    时间格式(yyyy-MM-dd HH:mm:ss)

//@return   NSString        返回字字符如（2012－8－8 11:11:11）

+ (NSString *)getDateStringWithDate:(NSDate *)date

                         DateFormat:(NSString *)formatString;

@end
