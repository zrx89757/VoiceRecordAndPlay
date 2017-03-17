//
//  JZRecordTool.m
//  jeezMSP
//
//  Created by 对河果农 on 17/3/10.
//  Copyright © 2017年 jeez. All rights reserved.
//

#import "JZAudioTool.h"
#import "UUAVAudioPlayer.h"


//static NSTimeInterval const audioLengthLimit = 600.0;

@interface JZAudioTool ()<AVAudioRecorderDelegate,UUAVAudioPlayerDelegate>
{
    AVAudioSession *_audioSession;
    NSString *_currentPath;
//    NSTimer *_audioLimitTimer;
    UUAVAudioPlayer *_audioPlayer;
    bool _successCalled;
}
@end

@implementation JZAudioTool
- (instancetype)init {
    if (self = [super init]) {
        _audioPlayer = [UUAVAudioPlayer sharedInstance];
        _audioPlayer.delegate = self;
    }
    return self;
}
- (void)playLastestRecord {
    [_audioPlayer playSongWithUrl:[self getLastestPath]];
}
- (void)continuePlaying {
    [_audioPlayer.player play];
}
- (void)pausePlaying {
    [_audioPlayer.player pause];
}
- (void)stopPlaying {
    [_audioPlayer.player stop];
}
- (void)beginRecordVoice {
    
    [self setSesstion];
    [self setRecorder];
    
    [_audioRecorder record];
//    _audioLimitTimer = [NSTimer timerWithTimeInterval:audioLengthLimit target:self selector:@selector(endRecordVoice) userInfo:nil repeats:NO];
//    [[NSRunLoop currentRunLoop] addTimer:_audioLimitTimer forMode:NSRunLoopCommonModes];

}
- (void)stopRecord {
    [_audioRecorder stop];
}
- (BOOL)isRecording {
    return [_audioRecorder isRecording];
}
- (BOOL)isPlayingRecord {
    return [_audioPlayer audioIsPlaying];
}
- (BOOL)haveRecord {
    if ((_currentPath && _currentPath.length > 0) && _successCalled) {
        return YES;
    }
    return NO;
}
- (void)removeLastestVoiceRecord {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_currentPath]) {
        NSError *err;
        [fileManager removeItemAtPath:_currentPath error:&err];
        if (err) {
            NSLog(@"删除最新录音失败:%@",err.debugDescription);
        }
        NSLog(@"删除最新录音");
    }
}
- (void)endRecordVoice
{
//    if (!_audioLimitTimer) {
//        return;
//    }
//    [_audioLimitTimer invalidate];
//    _audioLimitTimer = nil;
    //录音完成
    [self succeedRecord];
}
- (void)succeedRecord{
//    double cTime = _audioRecorder.currentTime;
    [_audioRecorder stop];
    _successCalled = YES;
//    if ( cTime >= audioLengthLimit) {
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        if ([self.delegate respondsToSelector:@selector(reachRecordLimitTime)]) {
//            [self.delegate reachRecordLimitTime];
//        }
//    }
}

- (NSString *)getLastestPath {
    return _currentPath;
}

- (void)setSesstion
{
    _audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(_audioSession == nil){
        NSLog(@"Error creating session: %@", [error description]);
    }else {
        [_audioSession setActive:YES error:nil];
    }
    error = nil;
    if ([_audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [_audioSession requestRecordPermission:^(BOOL available) {
            if (available) {
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *aleartView = [[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”选项中允许极致办公访问您的麦克风" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"现在设置", nil];
                    aleartView.tag = 1;
                    [aleartView show];
                });
            }
        }];
    }
}

- (void)setRecorder
{
    _audioRecorder = nil;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"AudioData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path
                                        isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
        if(!bCreateDir){
            
            NSLog(@"Create Audio Directory Failed.");
        }
        NSLog(@"%@",path);
    }
    
    NSString *dateUrl = [NSString stringWithFormat:@"%@.aac",[[NSDate date] toStringYMDHMS3]];
    path = [path stringByAppendingPathComponent:dateUrl];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSMutableDictionary *setting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [setting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [setting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [setting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [setting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [setting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    NSError *error;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                 settings:setting
                                                    error:&error];
    if (error) {
        NSLog(@"audioRecorder error:%@",error);
    }
    _currentPath = path;
    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder prepareToRecord];
    
}

#pragma mark  === UUAVAudioPlayerDelegate ===
//播放完成
- (void)UUAVAudioPlayerDidFinishPlay {
    if ([self.delegate respondsToSelector:@selector(recordVoiceFinishPlay)]) {
        [self.delegate recordVoiceFinishPlay];
    }
}

@end



