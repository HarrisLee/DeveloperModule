//
//  RespBody.h
//  eCity
//
//  Created by xuchuanyong on 11/26/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
@interface RespBody : BaseModel {
    NSString    *code;
    NSString    *pageSize;
    NSString    *jsonMsg;
}
@property (retain,nonatomic) NSString    *code;
@property (retain,nonatomic) NSString    *pageSize;
@property (retain,nonatomic) NSString    *value;
@property (retain,nonatomic) NSString    *jsonMsg;
@end
