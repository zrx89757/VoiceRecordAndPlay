//
//  UIView+Show.m
//  VoiceRecordAndPlay
//
//  Created by 对河果农 on 17/3/16.
//  Copyright © 2017年 Orange_zz. All rights reserved.
//

#import "UIView+Show.h"
#import "PopoverBackgroundView.h"

@implementation UIView (Show)

- (void)showPopoverLeftTopPointAt:(CGPoint)point inView:(UIView *)view backgroundColor:(UIColor *)color {
    PopoverBackgroundView *backgrounView = [[PopoverBackgroundView alloc]init];
    backgrounView.disRemoveWhenTouchesBegan = NO;
    backgrounView.backgroundColor = color;
    CGPoint topPoint = [backgrounView convertPoint:point fromView:view];
    [backgrounView addSubview:self];
    self.frame = CGRectMake(topPoint.x, topPoint.y, self.frame.size.width, self.frame.size.height);
}


@end
