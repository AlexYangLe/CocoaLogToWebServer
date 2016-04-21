//
//  Common.h
//  CocoaLogToWebServer
//
//  Created by 杨乐乐 on 16/4/21.
//  Copyright © 2016年 alex. All rights reserved.
//

#ifndef Common_h
#define Common_h

#ifdef __OBJC__
#import "DDTTYLogger.h"
#import "DDDBLogger.h"
#import "DDDBLogFormatter.h"
#import "DDLogMacros.h"
#import "DDLog.h"
#import "DBConnect.h"
#import "logSqlModel.h"
#import "DDLogCrash.h"
#import "ExLogger.h"
#endif

#ifndef DEBUG
static const int ddLogLevel = DDLogLevelDebug;
#else
static const int ddLogLevel = DDLogLevelInfo;
#endif

#ifndef DEBUG
#define NSLog(format, ...)
#else
#define NSLog(format, ...) DDLogWarn(format, ##__VA_ARGS__)
#endif

#define DDAssert(condition, frmt, ...)                                    \
if (!(condition)) {                                                       \
NSString *description = [NSString stringWithFormat:frmt, ## __VA_ARGS__]; \
DDLogError(@"%@", description);                                           \
NSAssert(NO, description);                                                \
}
#define DDAssertCondition(condition) DDAssert(condition, @"Condition not satisfied: %s", #condition)



#endif /* Common_h */
