//
//  DDDBLogFormatter.m
//  myLogToDB
//
//  Created by Gump on 16/4/14.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import "DDDBLogFormatter.h"

@implementation DDDBLogFormatter

//实现代理协议format方法
-(NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSMutableDictionary *logDic = [NSMutableDictionary  dictionary];
    
    NSString *locationString;
    NSArray *parts = [logMessage->_file componentsSeparatedByString:@"/"];
    if (parts.count > 0)
    {
        locationString = [parts lastObject];
    }
    if (parts.count == 0)
    {
        locationString = @"no file";
    }
    
    logDic[@"gampTech"] = [NSString stringWithFormat:@"%@:%lu(%@):%@", locationString, (unsigned long)logMessage.line, logMessage.function, logMessage.message];
    //NSMutableDictionary 转成 NSString
    NSError *error;
    NSData *outputJsonData = [NSJSONSerialization dataWithJSONObject:logDic options:0 error:&error];
    if (error) {
        return @"{\"gampTech\":\"error\"}";
    }
    NSString *outputJsonStr = [[NSString alloc] initWithData:outputJsonData encoding:NSUTF8StringEncoding];
    if (outputJsonStr) {
        return outputJsonStr;
    }
    return @"{\"gampTech\":\"error\"}";
}

@end
