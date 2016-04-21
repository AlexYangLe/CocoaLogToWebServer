//
//  logSqlModel.m
//  myLogToDB
//
//  Created by Gump on 16/4/15.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import "logSqlModel.h"

@implementation logSqlModel

-(instancetype)init
{
    if (self = [super init]) {
        _countSqlStr = @"SELECT count(*) FROM logMessageHistory";
        _insertSqlStr = @"INSERT INTO logMessageHistory (logtime,filename,line,function,message, level,lastUpdateTime) VALUES (?, ?, ?, ?, ?, ?, ?)";
        _updateDataSqlStr = @"UPDATE logMessageHistory SET logtime = ?, filename = ?, line = ?, function = ?, message = ?, level = ?, lastUpdateTime = ? order by lastUpdateTime limit 1";
        _queryDataSqlStr = @"SELECT logtime,filename,line,function,message,level,lastUpdateTime FROM logMessageHistory";
    }
    return self;
}

@end
