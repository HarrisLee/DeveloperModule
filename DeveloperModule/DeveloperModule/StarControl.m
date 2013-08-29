//
//  StarControl.m
//  eCity
//
//  Created by 徐 传勇 on 13-2-17.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "StarControl.h"

#define MAX_VALUE       5

#define STAR_SIZE       9

#define STAR_SPACE      1

@implementation StarControl
@dynamic score;

- (id)init {
    self = [super init];
    if (self) {
        [self initStarWithSize:STAR_SIZE withSpace:STAR_SPACE];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame withStarSize:(NSInteger)size withSpace:(NSInteger)space
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStarWithSize:size withSpace:space];
    }
    return self;
}

- (void)initStarWithSize:(NSInteger) size withSpace:(NSInteger) space {
    for (int i = 0; i < MAX_VALUE; i++) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake((size+space)*i, 0, size, size)];
        imgV.tag = i+1;
        imgV.image = [UIImage imageNamed:@"gold_star_gray"];
        [self addSubview:imgV];
        [imgV release];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStarWithSize:9 withSpace:1];
    }
    return self;
}

- (id)initWithValue:(CGFloat)value {
    self = [self init];
    if (self) {
        [self setScore:value];
    }
    return self;
}

- (UIImageView*)getImageViewWithTag:(NSInteger)tag {
    UIView *view = [self viewWithTag:tag];
    if ([view isKindOfClass:[UIImageView class]]) {
        return (UIImageView*)view;
    }
    return nil;
}

- (CGFloat)score {
    return score;
}

- (void)setScore:(CGFloat)value {
    
    int baseValue = value;
    score = baseValue;
//    NSLog(@"%d  %f",baseValue,value);
    for (int i = 0; i < baseValue; i++) {
        UIImageView *imgV = [self getImageViewWithTag:i+1];
        imgV.image = [UIImage imageNamed:@"gold_star_yellow"];
    }
    for (int i = baseValue; i < MAX_VALUE; i++) {
        UIImageView *imgV = [self getImageViewWithTag:i+1];
        imgV.image = [UIImage imageNamed:@"gold_star_gray"];
    }
    if (baseValue +0.5 <= value && value < baseValue + 1) {
        UIImageView *imgV = [self getImageViewWithTag:baseValue+1];
        imgV.image = [UIImage imageNamed:@"gold_star_half"];
        score = baseValue +0.5;
    }
    if (value > MAX_VALUE) {
        score = MAX_VALUE;
    }
    else if (value < 0) {
        score = 0;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self setScore:point.x/(STAR_SIZE+STAR_SPACE)];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self setScore:point.x/(STAR_SIZE+STAR_SPACE)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self setScore:point.x/(STAR_SIZE+STAR_SPACE)];
    self.userInteractionEnabled = NO;
//    NSLog(@"%f",self.score);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
