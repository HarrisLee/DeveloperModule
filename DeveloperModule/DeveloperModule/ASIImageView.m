//
//  ASIImageView.m
//  eCity
//
//  Created by MeGoo on 11/28/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//

#import "ASIImageView.h"
#import <objc/runtime.h>

static const char *returnDelegate = "returnDelegate";

@implementation UIImageView(ASIImageView)
@dynamic returnDelegate;
- (void)setReturnDelegate:(id)delegate {
    objc_setAssociatedObject(self, &returnDelegate, delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id)returnDelegate {
    return objc_getAssociatedObject(self, &returnDelegate);
}
- (id)initWithUrl:(NSString*)urlStr {
    self = [super init];
    if (self) {
        [self setUrl:urlStr];
        
    }
    return self;
}

- (void)setUrl:(NSString*)urlStr {
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    NSString *str = [urlStr stringByReplacingOccurrencesOfString :@" " withString:@""];
    [[HttpRequestCenter shareInstance] requestImageWithUrl:str andImageView:self];
}

- (void)imageBack:(UIImage*)img {
    if (img) {
        self.image = img;
        self.alpha = 0.0f;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.6];
        self.alpha = 1.0f;
        [UIView commitAnimations];
        if (self.returnDelegate && [self.returnDelegate respondsToSelector:@selector(returnUIImage:)]) {
            [self.returnDelegate returnUIImage:self];
        }
    }
}

@end
