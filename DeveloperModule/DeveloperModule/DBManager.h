//
//  DBManager.h
//  TylooMall
//
//  Created by 徐 传勇 on 13-3-6.
//  Copyright (c) 2013年 徐 传勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

#define DB_FILE_PATH        [Utils getDstFilePath:@"TylooMall.db" withFolder:@"DataBase"]

@interface BaseModel : NSObject {
    NSString                *primaryKey;        //主键
    NSMutableDictionary     *operateDic;        //用于修改，删除,查询
    NSInteger               rowId;
}
- (id)primaryKey;
- (void)setPrimaryKey:(NSString*)key;

- (NSMutableDictionary*)operateDic;
- (void)setOperateDic:(NSMutableDictionary*)dic;

- (NSInteger)rowId;
- (void)setRowId:(NSInteger)rId;

@end

@interface DBManager : NSObject
+(DBManager *)defaultDBManager;

- (void)createTableWith:(Class)objClass;
- (BOOL)insertToDB:(BaseModel*)model;
- (BOOL)insertData:(NSArray*)dataArray;
- (BOOL)deleteModel:(BaseModel*)model;
- (BOOL)updateModel:(BaseModel*)model;
- (NSArray*)selectData:(BaseModel*)model orderBy:(NSString *)columeName offset:(int)offset count:(int)count;
@end
