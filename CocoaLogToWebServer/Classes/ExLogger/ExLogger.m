//
//  ExLogger.m
//  ExLogger
//
//  Created by Gump on 16/4/15.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "Common.h"

@implementation ExLogger

static BOOL isStarted;
static GCDWebServer *_webServer;

+(void)prepare{
    //TODO 初始化DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDDBLogger *logger = [[DDDBLogger alloc] init];
    [logger setLogFormatter:[DDDBLogFormatter new]];
    [logger setSaveDBTotalNum:2000];
    [DDLog addLogger:logger];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

//从数据库查询日志
+(NSArray*)logsFromDB{
    logSqlModel *logSql = [[logSqlModel alloc] init];
    return [[DBConnect shareConnect] getDBlist:logSql.queryDataSqlStr];
}

+(BOOL)startService{
    NSLog(@"start service! _webserver=%@",_webServer);
    if (isStarted) {
        return NO;
    }
    if(!_webServer)
        _webServer = [[GCDWebServer alloc] init];
    
    //首页请求
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse*(GCDWebServerRequest *request){
        NSError *err;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
        NSLog(@"path:%@",path);
        GCDWebServerResponse *response = [GCDWebServerDataResponse responseWithHTML:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err]];
        return response;
    }];
    //日志数据请求
    [_webServer addHandlerForMethod:@"GET" path:@"/logs" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse*(GCDWebServerRequest *request){
        NSArray *array  = [self logsFromDB];
        
        return [GCDWebServerDataResponse responseWithJSONObject:array];
    }];
    
    isStarted = [_webServer startWithPort:8089 bonjourName:nil];
    return isStarted;

}

+(void)stopService{
    [_webServer stop];
    isStarted= NO;
    _webServer = nil;

}

+(BOOL)isStarted{
    return isStarted;
}

@end
