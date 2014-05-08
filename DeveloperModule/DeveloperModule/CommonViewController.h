//
//  CommonViewController.h
//  eCity
//
//  Created by xuchuanyong on 11/22/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//
//  控制器父视图，一些公共的元素在这里定义
#import <UIKit/UIKit.h>

@interface CommonViewController : UIViewController {
    id <ViewJumpManagerDelegate> m_Delegate;
}
@property (nonatomic,assign) id <ViewJumpManagerDelegate> m_Delegate;
- (void)goBack;
@end
