//
//  StarControl.h
//  eCity
//
//  Created by 徐 传勇 on 13-2-17.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarControl : UIView {
    CGFloat score;
}
@property CGFloat score;

//根据分数进行初始化
- (id)initWithValue:(CGFloat)value;
-(id) initWithFrame:(CGRect)frame withStarSize:(NSInteger)size withSpace:(NSInteger)space;

@end
