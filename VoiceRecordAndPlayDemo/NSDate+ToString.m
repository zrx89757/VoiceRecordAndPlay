//
//  NSDate+ToString.m
//  VoiceRecordAndPlay
//
//  Created by 对河果农 on 17/3/16.
//  Copyright © 2017年 Orange_zz. All rights reserved.
//

#import "NSDate+ToString.h"

@implementation NSDate (ToString)
- (NSString*)toStringYMDHMS3
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [dateFormat stringFromDate:self];
}

@end
