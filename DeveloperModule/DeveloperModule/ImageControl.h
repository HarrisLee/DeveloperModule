//
//  ImageControl.h
//  eCity
//
//  Created by 徐 传勇 on 13-5-9.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIImageView.h"

@interface ImageControl : NSObject <UIScrollViewDelegate,returnImg> {
    UIView          *contentView;
    UIScrollView    *imageScrollView;
    UIImageView     *imageView;
    UIButton        *downloadBtn;
    UIButton        *shareBtn;
    CGRect          mainViewFrame;
    NSString        *imageUrl;
    NSString        *imageTitle;
    BOOL            imageSaved;     //图片是否已被存储
}
@property (nonatomic,retain) NSString        *imageUrl;
@property (nonatomic,retain) NSString        *imageTitle;

- (id)initWithImage:(UIImage*)image;
- (id)initWithUrl:(NSString*)imageUrl andImageTitle:(NSString*)title;
- (void)show;
@end
