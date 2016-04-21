//
//  DDDBLogger.h
//  myLogToDB
//
//  Created by Gump on 16/4/14.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import "DDAbstractDatabaseLogger.h"

@interface DDDBLogger : DDAbstractDatabaseLogger

@property (readwrite, assign) NSInteger saveDBTotalNum;

@end
