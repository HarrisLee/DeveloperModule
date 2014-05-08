//
//  ASIImageView.h
//  eCity
//
//  Created by MeGoo on 11/28/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol returnImg <NSObject>
- (void)returnUIImage:(UIImageView*)img;
@end

@interface  UIImageView (ASIImageView)
@property(nonatomic, assign)id<returnImg>returnDelegate;

- (id)initWithUrl:(NSString*)urlStr;
- (void)setUrl:(NSString*)urlStr;
- (void)imageBack:(UIImage*)img;
@end
