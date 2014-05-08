//
//  CheckVesion.m
//  TyLooMall
//
//  Created by MeGoo on 13-3-8.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "CheckVesion.h"
/*
 Option 1 (DEFAULT): NO gives user option to update during next session launch
 Option 2: YES forces user to update app on launch
 */
static BOOL vesionForceUpdate = NO;
NSDictionary *appStoreInfo;
// 2. Your AppID (found in iTunes Connect)

#define kMyAppID                 @"6237899720000"
#define kMyAppID_iPad            @"6492983100000"

// 3. Customize the alert title and action buttons
#define kMyAlertViewTitle        @"更新提示"
#define kMyCancelButtonTitle     @"暂不更新"
#define kMyUpdateButtonTitle     @"立即更新"
#define kMyCurrentVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]

@interface CheckVesion ()

+ (void)showAlertWithAppStoreVersion;

@end

@implementation CheckVesion
#pragma mark - Public Methods
+ (void)checkVersionNeedToShow:(BOOL)isShow
{
    
    // Asynchronously query iTunes AppStore for publically available version
    NSString *storeString = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        storeString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kMyAppID];
    }
    else
    {
        storeString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kMyAppID_iPad];
    }
    NSURL *storeURL = [NSURL URLWithString:storeString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(isShow)
                [[HttpRequestCenter shareInstance] showMaskWithTimer:30 onView:nil];
            
        });
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:storeURL];
        NSDictionary *aDic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isShow],@"isShow",nil];
        request.userInfo = aDic;
        [aDic release];
        [request setRequestMethod:@"GET"];
        [request setDelegate:self];
        [request setShouldContinueWhenAppEntersBackground:YES];
        //    [request setDownloadProgressDelegate:self];
        //    [request setDidFinishSelector:@selector(requestDone:)];
        //    [request setDidFailSelector:@selector(requestWentWrong:)];
        [request startSynchronous];
        //    NSLog(@"%@",request.responseString);
        NSError *error = [request error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error)
            {
                [[HttpRequestCenter shareInstance] removeMask];
                NSData *respData = [request responseData];
                NSLog(@"%@",[request responseString]);
                if ( [respData length] > 0 && !request.error )
                { // Success
                    
                    SBJsonParser *parser = [[SBJsonParser alloc] init];
                    NSString *dataStr = [[[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding] autorelease];
                    NSDictionary *appData = [parser objectWithString:dataStr];
                    [parser release];
                    //        NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    
                    // All versions that have been uploaded to the AppStore
                    
                    NSArray *infoArray = [appData objectForKey:@"results"];
                    if ([infoArray count])
                    {
                        appStoreInfo = [[infoArray objectAtIndex:0] retain];
                        NSString *lastVersion = [appStoreInfo objectForKey:@"version"];
                        
                        if ([kMyCurrentVersion compare:lastVersion options:NSNumericSearch] == NSOrderedAscending) {
                            
                            [CheckVesion showAlertWithAppStoreVersion];
                            
                        }
                        else {
                            
                            // Current installed version is the newest public version or newer
                            [[HttpRequestCenter shareInstance] removeMask];
                            if(isShow)
                            {
                                alertMessage(@"当前已是最新版本，无需更新！");
                            }
                        }
                        
                    }
                    else
                    {
                        [[HttpRequestCenter shareInstance] removeMask];
                        if(isShow)
                        {
                            alertMessage(@"当前已是最新版本，无需更新！");
                        }
                    }
                }
            }
            else
            {
                [[HttpRequestCenter shareInstance] removeMask];
                BOOL isShow = [[request.userInfo objectForKey:@"isShow"] boolValue];
                if(isShow)
                {
                    alertMessage(@"网络异常，请检查网络！");
                }
            }
            
        });
        
        
        [request release];
        
        
    });
}

#pragma mark - Private Methods
+ (void)showAlertWithAppStoreVersion
{
    [[HttpRequestCenter shareInstance] removeMask];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    if ( vesionForceUpdate ) { // Force user to update app
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kMyAlertViewTitle
                                                            message:[NSString stringWithFormat:@"%@新版本%@出来了，请您立即更新！", appName, [appStoreInfo objectForKey:@"version"]]
                                                           delegate:self
                                                  cancelButtonTitle:kMyUpdateButtonTitle
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    } else { // Allow user option to update next time user launches your app
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kMyAlertViewTitle
                                                            message:[NSString stringWithFormat:@"%@新版本%@出来了，请您立即更新！", appName, [appStoreInfo objectForKey:@"version"]]
                                                           delegate:self
                                                  cancelButtonTitle:kMyCancelButtonTitle
                                                  otherButtonTitles:kMyUpdateButtonTitle, nil];
        
        [alertView show];
        
    }
    
}

#pragma mark - UIAlertViewDelegate Methods
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ( vesionForceUpdate ) {
        
        NSString *iTunesString = [appStoreInfo objectForKey:@"trackViewUrl"];
        NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
        [[UIApplication sharedApplication] openURL:iTunesURL];
        
    } else {
        
        switch ( buttonIndex ) {
                
            case 0:{ // Cancel / Not now
                
                // Do nothing436957167
                
            } break;
                
            case 1:{ // Update
                NSString *str = nil;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@", kMyAppID];
                }
                else
                {
                    str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@", kMyAppID_iPad];
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
            } break;
                
            default:
                break;
        }
        
    }
}

@end

