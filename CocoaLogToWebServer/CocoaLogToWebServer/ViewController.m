//
//  ViewController.m
//  CocoaLogToWebServer
//
//  Created by 杨乐乐 on 16/4/20.
//  Copyright © 2016年 alex. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"

@interface ViewController ()
@property(weak, nonatomic) IBOutlet UILabel* label;
@property(weak,nonatomic) IBOutlet UIButton *btn;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    if ([ExLogger isStarted]) {
        _label.text = [NSString stringWithFormat:NSLocalizedString(@"GCDWebServer running locally on port %i", nil), 8089];
    } else {
        _label.text = NSLocalizedString(@"GCDWebServer not running!", nil);
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)generateLog:(id)sender{
    NSLog(@"this is a new log! time:%@",[NSDate date]);
}

@end
