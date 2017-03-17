//
//  ViewController.m
//  VoiceRecordAndPlayDemo
//
//  Created by 对河果农 on 17/3/17.
//  Copyright © 2017年 Orange_zz. All rights reserved.
//

#import "ViewController.h"
#import "JZRecordView.h"
#import "JZVoiceRecordModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    JZRecordView *rv = [[JZRecordView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 180)];
    rv.recordCallback = ^(JZVoiceRecordModel *model) {
        NSLog(@"录音模型>>>>>>保存路径:%@\n录音时长:%ld秒",model.filePath,(long)model.voiceLength);
    };
    UIColor *bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [rv showPopoverLeftTopPointAt:CGPointMake(0, ScreenHeight-180) inView:self.view.window backgroundColor:bgColor];
}


@end
