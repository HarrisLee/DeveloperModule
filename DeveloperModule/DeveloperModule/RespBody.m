//
//  RespBody.m
//  eCity
//
//  Created by xuchuanyong on 11/26/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//

#import "RespBody.h"

@implementation RespBody
@synthesize code;
@synthesize pageSize;
@synthesize jsonMsg;
@dynamic value;

- (void)dealloc {
    [code release];
    [pageSize release];
    [jsonMsg release];
    [super dealloc];
}


- (void)setValue:(id)value {
    
}

@end
