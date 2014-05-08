//
//  UINavigationBar+CustomImage.m
//  eCity
//
//  Created by Melo on 13-8-6.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "UINavigationBar+CustomImage.h"

@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"BAC-1"];
    [image drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height+1)];
}

@end
