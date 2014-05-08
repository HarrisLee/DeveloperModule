//
//  CheckVesion.h
//  TyLoo
//
//  Created by MeGoo on 13-3-8.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckVesion : NSObject<UIAlertViewDelegate>

/*
 Checks the installed version of your application against the version currently available on the iTunes store.
 If a newer version exists in the AppStore, it prompts the user to update your app.
 */
+ (void)checkVersionNeedToShow:(BOOL)isShow;

@end