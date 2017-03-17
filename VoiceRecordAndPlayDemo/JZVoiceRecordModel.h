//
//  JZVoiceRecordModel.h
//  jeezMSP
//
//  Created by 对河果农 on 17/3/15.
//  Copyright © 2017年 jeez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JZVoiceRecordModel : NSObject
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,assign) NSInteger voiceLength;//语音时长
@end
