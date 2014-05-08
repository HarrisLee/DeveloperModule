//
//  ImageControl.m
//  eCity
//
//  Created by 徐 传勇 on 13-5-9.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "ImageControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageControl
@synthesize imageUrl;
@synthesize imageTitle;

- (id)init {
    self = [super init];
    if (self) {
        mainViewFrame = [self CGRectForOrientation];
        
        CGRect viewFrame = CGRectMake(0, 20, mainViewFrame.size.width, mainViewFrame.size.height-20);
        contentView = [[UIView alloc] initWithFrame:viewFrame];
        contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_INDEX"]];

        imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mainViewFrame.size.width, mainViewFrame.size.height-20)];
        imageScrollView.delegate=self;
        imageScrollView.multipleTouchEnabled=YES; //是否支持多点触控
        imageScrollView.minimumZoomScale=0.8;  //表示与原图片最小的比例
        imageScrollView.maximumZoomScale=5.0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [imageScrollView addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kViewWithNothing/2 - 360, 320, 180)];
        [imageView setImage:[UIImage imageNamed:@"LOADING3"]];
        [imageScrollView addSubview:imageView];
        
        [contentView addSubview:imageScrollView];
        
        UIImageView *footBack = [[UIImageView alloc] initWithFrame:CGRectMake(mainViewFrame.size.width-120-20, mainViewFrame.size.height-40-32, 120, 40)];
        footBack.image = [UIImage imageNamed:@"floatbar.png"];
        [contentView addSubview:footBack];
        [footBack release];
        
        UIImageView *downloadImg = [[UIImageView alloc] initWithFrame:CGRectMake(mainViewFrame.size.width-120-20+10, mainViewFrame.size.height-40-30+10, 15, 15)];
        downloadImg.image = [UIImage imageNamed:@"save_icon.png"];
        [contentView addSubview:downloadImg];
        [downloadImg release];
        
        downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.frame = CGRectMake(mainViewFrame.size.width-120-20, mainViewFrame.size.height-40-30, 60, 40);
        [downloadBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        [downloadBtn setTitle:@"保存" forState:UIControlStateNormal];
        [downloadBtn.titleLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
        [downloadBtn addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:downloadBtn];
        
        UIImageView *shareImg = [[UIImageView alloc] initWithFrame:CGRectMake(mainViewFrame.size.width-120-20+60+10, mainViewFrame.size.height-40-30+10, 15, 15)];
        shareImg.image = [UIImage imageNamed:@"share_icon.png"];
        [contentView addSubview:shareImg];
        [shareImg release];
        
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(mainViewFrame.size.width-120-20+60, mainViewFrame.size.height-40-30, 60, 40);
        [shareBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [shareBtn.titleLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
        [shareBtn addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:shareBtn];
        
        imageSaved = NO;
    }
    
    return self;
}

-(CGRect)CGRectForOrientation{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGRectMake(0, 0, kMainScreenBounds.size.height, kMainScreenBounds.size.width);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGRectMake(0, 0, kMainScreenBounds.size.height, kMainScreenBounds.size.width);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return kMainScreenBounds;
    } else {
        return kMainScreenBounds;
    }
}

- (void)shareImage:(UIButton*)sender {
    [[DataCenter shareInstance] shareContent:imageTitle title:@"图片分享" url:self.imageUrl image:self.imageUrl withSender:sender];
}

- (void)downloadImage {
    NSString *msg = nil;
    if (!imageSaved) {
        UIImageWriteToSavedPhotosAlbum([imageView image], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [[HttpRequestCenter shareInstance]showMaskWithTimer:60 onView:contentView];
    }
    else {
        msg = @"图片已被存储，请勿重复操作";
    }
    if (msg) {
        CAlertView *alert = [[CAlertView alloc] initWithTitle:@"图片存储"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    [[HttpRequestCenter shareInstance] removeMask];
    NSString *msg = nil;
    // Was there an error?
    if (error != NULL)
    {
        msg = @"请在“设置-隐私-照片”中打开“天禄奢品”的照片访问权限";
    }
    else  // No errors
    {
        imageSaved = YES;
         msg = @"您已将图片存储于图片库中，打开照片程序即可查看。";
    }
    CAlertView *alert = [[CAlertView alloc] initWithTitle:@"图片存储"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

- (void)viewTaped:(UIGestureRecognizer*)gesture {
    [self close];
}

- (void)setImageSize:(CGSize)iamgeSize {
    CGRect frame = mainViewFrame;
    CGFloat imageView_X = (iamgeSize.width > frame.size.width) ? frame.size.width : iamgeSize.width;
    CGFloat imageView_Y=(iamgeSize.height > frame.size.height) ? frame.size.height : iamgeSize.height;
    CGFloat origin;
    //保持图片的比例
    if(iamgeSize.width > frame.size.width){
        origin = frame.size.width/iamgeSize.width;
        imageView_Y = iamgeSize.height*origin;
    }
    imageView.frame = CGRectMake((frame.size.width-imageView_X)/2, (frame.size.height-imageView_Y)/2, imageView_X, imageView_Y);
}

- (id)initWithImage:(UIImage*)image {
    self = [self init];
    if (self) {
        imageView.image = image;
        [self setImageSize:image.size];
        
    }
    return self;
}

- (id)initWithUrl:(NSString*)url andImageTitle:(NSString *)title {
    self = [self init];
    if (self) {
        self.imageUrl = url;
        self.imageTitle = title;
        imageView.returnDelegate = self;
        [imageView setUrl:imageUrl];
        
    }
    return self;
}

- (void)returnUIImage:(UIImageView*)img {
    [self setImageSize:img.image.size];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}

- (void)show {
    [self retain];
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    UIViewController *rootViewController = mainWindow.rootViewController;
    [rootViewController.view addSubview:contentView];
}

- (void)close {
    [contentView removeFromSuperview];
    imageView.returnDelegate = nil;
    [self release];
}


- (void)dealloc {
    [imageView release];
    [imageScrollView release];
    [contentView release];
    [imageUrl release];
    [imageTitle release];
    [super dealloc];
}

@end
