//
//  CActivityIndicatorView.m
//  eCity
//
//  Created by 徐 传勇 on 13-6-28.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "CActivityIndicatorView.h"

@implementation CActivityIndicatorView
@synthesize progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        back.image = [UIImage imageNamed:@"gold_load_back"];
        [self addSubview:back];
        [back release];
        
        animationImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        animationImg.image = [UIImage imageNamed:@"gold_load_progress"];
        [self addSubview:animationImg];
        [animationImg release];
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        lineWidth = 10.0;
        backColor = [UIColor lightGrayColor];
        progressColor = [[UIColor colorWithRed:255.0f/255.0f green:199.0f/255.0f blue:0.0f/255.0f alpha:0.9] retain];
        self.progress = 0.0;
    }
    return self;
}

- (void)startAnimating {
    CATransform3D rotationTransform  = CATransform3DMakeRotation(M_PI, 0.0, 0, 1.0);
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue        = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration        = 0.5;
    animation.autoreverses    = NO;
    animation.cumulative    = YES;
    animation.repeatCount    = FLT_MAX;  //"forever"
    animation.beginTime        = 0.0;
    animation.delegate        = self;
    [animationImg.layer addAnimation:animation forKey:@"rotate"];
    [CAAnimation animation];
}

- (void)stopAnimating {
    [animationImg.layer removeAnimationForKey:@"rotate"];
    
}

- (void)redrawCycle {
    progress = progress +0.01;
    if (progress >1.0) {
        progress = 0.0;
    }
    [self setNeedsDisplay];
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
    [progressColor release];
    [super dealloc];
}

@end
