//
//  JZRecordView.h
//  jeezMSP
//
//  Created by 对河果农 on 17/3/10.
//  Copyright © 2017年 jeez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JZVoiceRecordModel;

@interface JZRecordView : UIView

@property (nonatomic,copy) void (^recordCallback)(JZVoiceRecordModel *);
@end
