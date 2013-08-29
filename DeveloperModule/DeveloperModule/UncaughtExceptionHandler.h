//
//  UncaughtExceptionHandler.h
//  LOLOrz
//
//  Created by 徐 传勇 on 13-1-15.
//  Copyright (c) 2013年 徐 传勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject {
    BOOL dismissed;
}

@end

void InstallUncaughtExceptionHandler();

