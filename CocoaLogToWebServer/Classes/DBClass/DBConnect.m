//
//  DBConnect.m
//  Ershixiong
//
//  Created by tw001 on 14-8-29.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "DBConnect.h"
#import <sqlite3.h>
#import "FMDB.h"
#define SQLNAME @"gampTech.sqlite"

@implementation DBConnect

static DBConnect *dBHandle;

+ (DBConnect *)shareConnect
{
    if (dBHandle == nil) {
        dBHandle = [[DBConnect alloc] init];
        [dBHandle openDatabase];
    }
    return dBHandle;
}

+ (NSString *)bundleSQLPath
{
    return [[NSBundle mainBundle] pathForResource:@"mytable" ofType:@"sqlite"];
}

/// 打开数据库
- (void)openDatabase {
//    NSString *userDataBaseName = [NSString stringWithFormat:@"%@info.sqlite", [UserInfo shareInstance].userID];
    NSString *logDataBaseName = [NSString stringWithFormat:@"%@logInfo.sqlit",@"gampTech"];
    NSString *sqlPath = [[self getDocumentPath] stringByAppendingPathComponent:logDataBaseName];
    NSLog(@"%@", sqlPath); // 拼接字符串
    
    self.dataBase = [FMDatabase databaseWithPath:sqlPath];
    self.dbQueue  = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    
    [_dataBase open];
    if (![_dataBase open]) {
        NSLog(@"数据库打开失败");
    }else{
        NSLog(@"数据库打开成功");
        [self CreateNeedTable];
    }
}

/// 获得document文件的路径
- (NSString *)getDocumentPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // 获取document文件的路径
    return documentPath;
}

/// 判断是否存在表
- (BOOL)isTableOK:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = '%@'", tableName];
    int count = [self getDBDataCount:sql];
    if (count > 0) {
        return YES;
    }
    
    return NO;
}

/// 创建表
- (BOOL)createTableSql:(NSString *)sql
{
    [self executeInsertSql:sql];
    return YES;
}

/// 获得数据
- (NSArray *)getDBlist:(NSString *)sql {
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
            [list addObject:dictionary];
            return 0;
        }];
    }];
    
    return list;
}

/// 获得单条数据
- (NSDictionary *)getDBOneData:(NSString *)sql
{
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
            [list addObject:dictionary];
            return 0;
        }];
    }];
    
    if (list.count == 1) {
        return [list objectAtIndex:0];
    }
    
    return nil;
}

/// 统计数量
- (int)getDBDataCount:(NSString *)sql
{
    int count = 0;
    __block NSMutableArray *list = [[NSMutableArray alloc] init];

    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
            [list addObject:dictionary];
            return 0;
        }];
    }];
    
    if (list.count == 1) {
        NSDictionary *dict = [list objectAtIndex:0];
        if (dict) {
            count = [[dict objectForKey:@"count(*)"] intValue];
        }
    }
    
    return count;
}

/// 执行sql(主要用来执行插入操作)
- (unsigned)executeInsertSql:(NSString *)sql
{
    __block unsigned mid = 0;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeStatements:sql];
        sqlite_int64 lastId = [db lastInsertRowId];
        mid = (unsigned)lastId;
    }];
    
    return mid;
}

/// 更新操作，删除操作
- (void)executeUpdateSql:(NSString *)sql
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeStatements:sql];
    }];
}

/// 关闭数据库
- (void)closeDatabase
{
    [self.dataBase close];
}

/**
 *  创建表格
 */
/* Create Need table */
- (void)CreateNeedTable {
    // Create post table for storage post
    NSString *sql = [NSString stringWithFormat:@"create table if not exists logMessageHistory("
                     "logtime      text    default '', "        //日志打印时间
                     "filename  text    default '', "           //日志打印的文件名
                     "line      integer           , "           //日志打印的行数
                     "function  text    default '', "           //日志打印的函数名
                     "message   text    default '', "           //日志打印的日志内容
                     "level     integer           , "           //日志打印的级别
                     "lastUpdateTime DATETINE )"];              //日志记录更新的最后时间
    [dBHandle createTableSql:sql];
}


@end
