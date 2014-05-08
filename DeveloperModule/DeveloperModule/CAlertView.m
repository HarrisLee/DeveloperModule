//
//  CAlertView.m
//  eCity
//
//  Created by 徐 传勇 on 13-6-28.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "CAlertView.h"

@implementation CAlertView
@synthesize contentImage;

- (id)init
{
    if (self = [super init]) {
        self.contentImage = [UIImage imageNamed:@"gold_alertBack"];
    }
    return self;
}

- (void) layoutSubviews {

    //屏蔽系统的ImageView 和 UIButton
    for (UIView *v in [self subviews]) {
//        NSLog(@"%@",NSStringFromClass([v class]));
        if ([v class] == [UIImageView class]){
            UIImageView *imageView = (UIImageView*)v;
            imageView.image = contentImage;
        }
        if ([v isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)v;
            [label setTextColor:[UIColor blackColor]];
            [label setShadowOffset:CGSizeMake(0, 0)];
        }
        
        if ([v isKindOfClass:[UIButton class]] ||
            [v isKindOfClass:NSClassFromString(@"UIThreePartButton")]) {
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
                UIView *view = (UIView *)v;
                //                view.opaque = YES;
                //                view.backgroundColor = [UIColor clearColor];
                //                UIImageView *img = [[UIImageView alloc] initWithFrame:view.frame];
                //                img.contentMode = UIViewContentModeScaleToFill;
                //                img.clipsToBounds = YES;
                //                [img setImage:[UIImage imageNamed:@"ALERT_BUTTON_LEFT"]];
                //                [self addSubview:img];
                //                [img release];
                
                view.backgroundColor = [UIColor colorWithRed:250/255.0f green:205/255.0 blue:74/255.0f alpha:1.0];
            } else {
                UIButton *button = (UIButton*)v;
                [button setBackgroundImage:[[UIImage imageNamed:@"gold_alert_button_left"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            }
            
            //            CGRect btnFrame = button.frame;
            //            button.transform = CGAffineTransformMakeScale(100/btnFrame.size.width, 30/btnFrame.size.height);
        }
    }

}

- (void)drawRect:(CGRect)rect {
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [contentImage release];
    [super dealloc];
}

@end
