//
//  PopoverBackgroundView.m
//  jeezMSP
//
//  Created by yangyun on 14-6-12.
//  Copyright (c) 2014年 jeez. All rights reserved.
//

#import "PopoverBackgroundView.h"

@implementation PopoverBackgroundView
@synthesize disRemoveWhenTouchesBegan;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        UIWindow *window = appDelegate.window;

        self.frame = window.frame;
        [window addSubview:self];
        
        self.userInteractionEnabled = YES;



        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];

    if(!disRemoveWhenTouchesBegan){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JZYBCBScrollviewfamechange" object:nil];
        [self removeFromSuperview];
    }
    [self endEditing:YES];
}
@end
