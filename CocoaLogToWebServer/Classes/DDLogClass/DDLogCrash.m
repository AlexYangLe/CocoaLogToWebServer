//
//  DDLogCrash.m
//  ExLogger
//
//  Created by Gump on 16/4/18.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import "DDLogCrash.h"
#import "Common.h"

@implementation DDLogCrash

void uncaughtExceptionHandler(NSException *exception)
{
    //异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    //出现异常的原因
    NSString *reason = [exception reason];
    //异常名称
    NSString *name = [exception name];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception resaon: %@\n Exception name: %@\n Exception static: %@", name, reason, stackArray];
    DDLogError(@"%@",exceptionInfo);
    
    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

@end
