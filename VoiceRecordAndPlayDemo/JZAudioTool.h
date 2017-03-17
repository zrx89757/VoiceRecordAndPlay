//
//  JZRecordTool.h
//  jeezMSP
//
//  Created by 对河果农 on 17/3/10.
//  Copyright © 2017年 jeez. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol JZAudioToolDelegate <NSObject>
@optional
//录音播放完毕
- (void)recordVoiceFinishPlay;
//到达录音限制时长
- (void)reachRecordLimitTime;
@end

@interface JZAudioTool : NSObject
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
//从界面弹出来开始，有没有完成的录音
@property (nonatomic,assign) BOOL haveRecord;
@property (nonatomic,weak) id<JZAudioToolDelegate>delegate;

//开始录音
- (void)beginRecordVoice;
//结束录音
- (void)endRecordVoice;
//播放最新录音
- (void)playLastestRecord;
//删除最新录音
- (void)removeLastestVoiceRecord;
//是否正在播放录音
- (BOOL)isPlayingRecord;
//暂停录音播放
- (void)pausePlaying;
//继续播放录音
- (void)continuePlaying;
//停止播放录音
- (void)stopPlaying;
//是否正在录音
- (BOOL)isRecording;
//停止录音
- (void)stopRecord;
//获取最新录音的文件路径
- (NSString *)getLastestPath;
@end
