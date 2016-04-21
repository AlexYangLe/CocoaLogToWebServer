//
//  ExLogger.h
//  ExLogger
//
//  Created by Gump on 16/4/15.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExLogger : NSObject

+(void)prepare;

+(BOOL)startService;
+(void)stopService;

+(BOOL)isStarted;

@end
