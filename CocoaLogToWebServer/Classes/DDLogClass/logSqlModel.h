//
//  logSqlModel.h
//  myLogToDB
//
//  Created by Gump on 16/4/15.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface logSqlModel : NSObject

//统计数量的sql语句
@property (nonatomic, copy) NSString *countSqlStr;
//插入数据的sql语句
@property (nonatomic, copy) NSString *insertSqlStr;
//更新数据的sql语句(更新删除)
@property (nonatomic, copy) NSString *updateDataSqlStr;
//查询数据的sql语句
@property (nonatomic, copy) NSString *queryDataSqlStr;

-(instancetype)init;

@end
