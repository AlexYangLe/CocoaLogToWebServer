# CocoaLogToWebServer
通过使用CocoaLumberjack 和GCDWebServer实现日志NSLog打印的重定向，并且可以使用浏览器访问日志

###CocoaLumberjack数据库存储并在PC端web访问
这个题目存在两个问题：1、使用CocoaLumberjack将文件日志存储在数据库；2、使用PC端使用web访问；那接下来我们分别解决两个问题。
####1 使用CocoaLumberjack将日志文件存储到数据库
CocoaLumberjack的使用其他的地方都有就不在表述了，详细使用[CocoaLumberjack github地址](https://github.com/CocoaLumberjack/CocoaLumberjack)。

CocoaLumberjack的代码的流程，所有的log发送给DDlog对象，运行在自己的GCD队列（GlobalLoggingQueue），之后DDLog会将日志分发到其下注册的一个或多个Logger（并发），每个Logger处理受到的log，此时是在自己的GCD队列（loggerQueue）下操作的，然后分别执行其下的formatter，获取log应有的格式，最终将消息分发到不同的地方。

我们直奔主题，要存数据库，我们看文件目录：
![image.png](http://upload-images.jianshu.io/upload_images/1756292-8e1f9eb5fbddbe48.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这是我们需要注意的，这个文件说明我们需要将数据存储到数据库上的时候需要我们继承这个类，并将其中的方法重写。
我们定义自己的数据库存储文件：
```
//DDDBLogger.h

#import "DDAbstractDatabaseLogger.h"

@interface DDDBLogger : DDAbstractDatabaseLogger

@property (readwrite, assign) NSInteger saveDBTotalNum;

@end

```
实现：
```
#import "DDDBLogger.h"
#import "DBConnect.h"
#import "logSqlModel.h"


@interface DDDBLogger ()

@property (nonatomic, strong) DDLogMessage *saveDBLogMessage;


@end


@implementation DDDBLogger

//设置数据库存储的条数
- (void)setsaveDBTotalNum:(NSUInteger)threshold {
    dispatch_block_t block = ^{
        @autoreleasepool {
            if (_saveDBTotalNum != threshold) {
                _saveDBTotalNum = threshold;
            }
        }
    };
//判断是否在自己logger GCD队列中
    if ([self isOnInternalLoggerQueue]) {
        block();
    } else {
        dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
        NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
        
        dispatch_async(globalLoggingQueue, ^{
            dispatch_async(self.loggerQueue, block);
        });
    }
}



-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.deleteOnEverySave = NO;
        self.saveInterval = 1;         //1 seconds，1秒发送一次
        self.saveThreshold = 1;       //每一条就发送
        self.saveDBTotalNum = 2000;   //数据库总共存2000 条
    }
    return  self;
};


- (BOOL)db_log:(DDLogMessage *)logMessage
{
    //没有日志信息
    if(!_logFormatter)
    {
        return NO;
    }
    _saveDBLogMessage = logMessage;
    return YES;
}

- (void)db_save {
    if ([self isOnGlobalLoggingQueue]) {
        NSAssert(NO, @"db_saveAnddelete should only be executed on the internaLoggerQueue thread, if you are seeing this, your doing it wrong");
    }

    [self saveLogEntries:self.saveDBLogMessage];
}


-(void)saveLogEntries:(DDLogMessage *)logMessage
{
    logSqlModel *logSql = [[logSqlModel alloc] init];
    
    //获取当前的数据库中村的数据的条数
    //统计数据库数据条数的sql
    NSInteger saveDBNum = [[DBConnect shareConnect] getDBDataCount: logSql.countSqlStr];
    NSString *logTimeStr = [self stringFromDate:logMessage.timestamp];
    NSString *line = [NSString stringWithFormat:@"%lu", (unsigned long)logMessage.line];
    NSString *level = [NSString stringWithFormat:@"%lu", (unsigned long)logMessage.level];
    
    if (_saveDBTotalNum < saveDBNum)
    {
        //数据库中存储的数据条数 大于 要求存储的条数
        //删除的数据条数
        NSInteger deleteNum = saveDBNum - _saveDBTotalNum;
        NSString *deleteDataSqlStr = [NSString stringWithFormat:@"DELETE FROM logMessageHistory order by lastUpdateTime limit %ld", (long)deleteNum];
        [[DBConnect shareConnect] executeUpdateSql:deleteDataSqlStr];
    }else if (_saveDBTotalNum > saveDBNum) {
        //数据库能保存的数据多余现在的数据，就是直接插入数据库
        [[DBConnect shareConnect].dataBase executeUpdate:logSql.insertSqlStr,logTimeStr, logMessage.fileName, line, logMessage.function, logMessage.message, level, logMessage.timestamp];
    }
    else{
        //数据库已经存满，此时需要update时间最早的数据
        [[DBConnect shareConnect].dataBase executeUpdate: logSql.updateDataSqlStr,logTimeStr, logMessage.fileName, line, logMessage.function, logMessage.message, level, logMessage.timestamp];
    }
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
@end
```
我们封装完Logger对象之后，我们需要实现LogFormatter，那么我们的DDDBLogFormatter的声明和实现：
```
#import <Foundation/Foundation.h>
#import "DDLog.h"
@interface DDDBLogFormatter : NSObject<DDLogFormatter>
@end
```
实现：
```
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
```
其中logSqlModel.h是我将sql封装之后的语句demo。
我们在需要CocoaLumberjack的同时还需要FMDB和GCDWebserver，前者数据库存储，后者建立网络访问。
####2 PC端通过网络访问
在本地资源文件bundle中创建一个html,此HTML是返回的界面。
```
<!doctype html>
<html>
<head>
<script src="http://code.angularjs.org/angular-1.0.1.min.js"></script>

</head>
<body ng-app="myApp" ng-controller="mainCtrl">

<button ng-click="refresh()">refresh</button>
<div  style="background: #07242E; color: #708284;height: auto;overflow: auto;min-height: 600px;max-height:700px" >

<ul>
<li ng-repeat="x in items" style='font-size:15px'>
    {{ x.logtime }} &nbsp; [{{x.level}}]-{{x.filename}}:{{x.line}}/{{x.function}} &nbsp;=> {{x.message}}
</li>
</ul>

</div>

<script>
var app = angular.module('myApp', []);

app.controller('mainCtrl', function($scope, $http) {
    $http.get(location+'logs').success(function(response) {
                                 $scope.items = response;
                             });
    $scope.refresh = function(){
                    $http.get(location+'logs').success(function(response){
                                                  $scope.items = response;
                                              });
    };
});

</script>
</body>
</html>
```
接下来我们看GCDWebServer的调用本地方法列表：
```
#import <Foundation/Foundation.h>

@interface ExLogger : NSObject
+(void)prepare;
+(BOOL)startService;
+(void)stopService;
+(BOOL)isStarted;
@end
```
实现：
```
#import "ExLogger.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@implementation ExLogger

static BOOL isStarted;
static GCDWebServer *_webServer;

+(void)prepare{
    //TODO 初始化DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //声明我们自己的Logger
    DDDBLogger *logger = [[DDDBLogger alloc] init];
    [logger setLogFormatter:[DDDBLogFormatter new]];
    [logger setSaveDBTotalNum:2000];
    [DDLog addLogger:logger];
    //捕获异常数据
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
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingFormat:@"/%@/template.html", kBundleName];
        NSLog(@"path:%@",path);
        GCDWebServerResponse *response = [GCDWebServerDataResponse responseWithHTML:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err]];
        return response;
    }];
    //点击refresh按钮时请求日志数据
    [_webServer addHandlerForMethod:@"GET" path:@"/logs" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse*(GCDWebServerRequest *request){
        NSArray *array  = [self logsFromDB];
        
        return [GCDWebServerDataResponse responseWithJSONObject:array];
    }];
    
    isStarted = [_webServer startWithPort:8089 bonjourName:nil];
    return isStarted;

}

+(void)stopService{
    [_webServer stop];
    [DDLog removeAllLoggers];
    isStarted= NO;
    _webServer = nil;

}

+(BOOL)isStarted{
    return isStarted;
}

@end

```
此时我们就可以在手机的IP加上端口8089，在PC端查看。
(我的demo地址)[https://github.com/yanduhantan563/CocoaLogToWebServer]
```
-> CocoaLogToWebServer (1.0.0)
   通过使用CocoaLumberjack 和GCDWebServer实现日志NSLog打印的重定向，并且可以使用浏览器访问日志
   pod 'CocoaLogToWebServer', '~> 1.0.0'
   - Homepage: https://github.com/yanduhantan563/CocoaLogToWebServer
   - Source:   https://github.com/yanduhantan563/CocoaLogToWebServer.git
   - Versions: 1.0.0 [master repo]
```


