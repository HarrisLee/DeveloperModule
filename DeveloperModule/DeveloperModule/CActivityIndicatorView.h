//
//  CActivityIndicatorView.h
//  eCity
//
//  Created by 徐 传勇 on 13-6-28.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CActivityIndicatorView : UIView {
    UIImageView     *animationImg;
    CGFloat         lineWidth;
    UIColor         *backColor;
    UIColor         *progressColor;
    CGFloat         progress;
    
    NSTimer         *roundTimer;
}
@property CGFloat   progress;

- (void)startAnimating;
- (void)stopAnimating;

@end
