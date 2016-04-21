//
//  DDLogCrash.h
//  ExLogger
//
//  Created by Gump on 16/4/18.
//  Copyright © 2016年 Gump. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDLogCrash : NSObject

void uncaughtExceptionHandler(NSException *exception);

@end
