//
//  JZRecordView.m
//  jeezMSP
//
//  Created by 对河果农 on 17/3/10.
//  Copyright © 2017年 jeez. All rights reserved.
//

#import "JZRecordView.h"
#import "SpectrumView.h"
#import "JZAudioTool.h"
#import "JZVoiceRecordModel.h"

#define VoiceLength @"10" //默认录音最长10分钟

@interface JZRecordView ()<JZAudioToolDelegate>
{
    NSInteger _secondCount;
    NSInteger _voiceLength;//语音时长
    dispatch_source_t _gcdTimer;//iOS三大计时器中最精确的类型
}
@property (nonatomic,strong) JZAudioTool *tool;
@property (nonatomic,strong) SpectrumView *specView;
@property (nonatomic,strong) UILabel *teachLb;
@property (nonatomic,strong) UILabel *tipLb;
@property (nonatomic,strong) UIView *btnBgView;
@property (nonatomic,strong) UIButton *funcBtn;

@end

@implementation JZRecordView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (UILabel *)getLabel:(CGRect)frame fontSize:(CGFloat)size text:(NSString *)text {
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    lb.textColor = [UIColor colorWithHexString:@"#787878"];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.font = [UIFont systemFontOfSize:size];
    lb.text = text;
    return lb;
}
- (UILabel *)getLine:(CGRect)frame {
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    lb.backgroundColor = [UIColor ColorJeezToLineWithalpha:1.0];
    return lb;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tool = [[JZAudioTool alloc] init];
        _tool.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        UILabel *teachLb = [self getLabel:CGRectMake(self.frame.size.width/2-35, 20, 70, 20) fontSize:15 text:@"点击录音"];
        [self addSubview:teachLb];
        self.teachLb = teachLb;
        
        UIButton *mainBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 68, 68)];
        [mainBtn setImage:[UIImage imageNamed:@"record_ready"] forState:UIControlStateNormal];
        [mainBtn addTarget:self action:@selector(funcButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mainBtn];
        CGPoint center = CGPointMake(self.center.x, 89);
        mainBtn.center = center;
        self.funcBtn = mainBtn;
        
        UILabel *tipLb = [self getLabel:CGRectMake(0, 0, 120, 20) fontSize:14 text:@"最长可录音10分钟"];
        [self addSubview:tipLb];
        CGPoint c = CGPointMake(self.center.x, CGRectGetMaxY(mainBtn.frame)+20);
        tipLb.center = c;
        tipLb.hidden = YES;
        self.tipLb = tipLb;
        
        UIView *btnBgView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-40.5, self.frame.size.width, 40.5)];
        [self addSubview:btnBgView];
        btnBgView.userInteractionEnabled = YES;

        [btnBgView addSubview:[self getLine:CGRectMake(0, 0, self.frame.size.width, 0.5)]];
        
        UILabel *cancel = [self getLabel:CGRectMake(0, 0.5, self.frame.size.width/2.0-0.25, 40) fontSize:18 text:@"取消"];
        [btnBgView addSubview:cancel];
        UITapGestureRecognizer *ct = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        [cancel addGestureRecognizer:ct];
        cancel.userInteractionEnabled = YES;
        
        UILabel *done = [self getLabel:CGRectMake(self.frame.size.width/2.0+0.25, 0.5, self.frame.size.width/2.0-0.25, 40) fontSize:18 text:@"完成"];
        [btnBgView addSubview:done];
        UITapGestureRecognizer *dt = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doneAction)];
        [done addGestureRecognizer:dt];
        done.userInteractionEnabled = YES;

        [btnBgView addSubview:[self getLine:CGRectMake(self.frame.size.width/2.0-0.25, 0.5, 0.5, 40)]];

        self.btnBgView = btnBgView;
        self.btnBgView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchToRemove) name:@"JZYBCBScrollviewfamechange" object:nil];
    }
    return self;
}
- (void)addSpectrumView {
    [self.teachLb removeFromSuperview];
    SpectrumView *spectrumView = [[SpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame)-100,10,200,40)];
    spectrumView.text = @"00:00";
    WeakSelf(ws);
    __weak SpectrumView * weakSpectrum = spectrumView;
    spectrumView.itemLevelCallback = ^() {
        [ws.tool.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围时-160到0
        float power= [ws.tool.audioRecorder averagePowerForChannel:0];
        weakSpectrum.level = power;
    };
    self.specView = spectrumView;
    [self addSubview:spectrumView];
}
- (void)touchToRemove {
    //点击遮罩层空白处
    [self beforeDismiss];
}
- (void)beforeDismiss {
    if ([_tool isRecording]) {
        [_tool stopRecord];
    }
    if ([_tool isPlayingRecord]) {
        [_tool stopPlaying];
    }
    if (_gcdTimer) {
        dispatch_cancel(_gcdTimer);
    }
    [_tool removeLastestVoiceRecord];
}
//点击取消
- (void)cancelAction {
    [self beforeDismiss];
    [self.superview removeFromSuperview];
    if ([UIDevice currentDevice].systemVersion.floatValue > 9.0) {
        [self removeFromSuperview];
    }
}
//点击完成
- (void)doneAction {
    if ([_tool isPlayingRecord]) {
        [_tool stopPlaying];
    }
    if (_gcdTimer) {
        dispatch_cancel(_gcdTimer);
    }

    JZVoiceRecordModel *model = [[JZVoiceRecordModel alloc] init];
    model.filePath = [_tool getLastestPath];
    model.voiceLength = _voiceLength;
    model.fileName = [model.filePath componentsSeparatedByString:@"/"].lastObject;
    if (self.recordCallback) {
        self.recordCallback(model);
    }
    [self.superview removeFromSuperview];
    if ([UIDevice currentDevice].systemVersion.floatValue > 9.0) {
        [self removeFromSuperview];
    }

}

- (NSInteger)setSpecViewTextWithSeconds:(NSInteger)count {
    NSInteger secondR = count % 10;
    NSInteger secondL = count % 60 / 10;
    NSInteger minuteR = count % 600 / 60;
    NSInteger minuteL = count / 600;
    self.specView.text = [NSString stringWithFormat:@"%ld%ld:%ld%ld",(long)minuteL,(long)minuteR,(long)secondL,(long)secondR];
    return count / 60;
}
- (dispatch_source_t)createGCDTimer {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, start, interval, 0);
    return timer;
    
}
- (void)addRecordGCDTimer {
    _secondCount = 0;
    _gcdTimer = [self createGCDTimer];
    dispatch_source_set_event_handler(_gcdTimer, ^{
        self->_secondCount ++;
        NSInteger minutes = [self setSpecViewTextWithSeconds:self->_secondCount];
        if (minutes >= VoiceLength.intValue-1) {
            //录音比限制时长小1分钟的时候，出现提示信息
            self.tipLb.hidden = NO;
        }
        if (minutes == VoiceLength.intValue) {
            //到达限制录音时长
            [self manualEndRecord];
        }
    });
    // 启动定时器
    dispatch_resume(_gcdTimer);
}
- (void)addPlayGCDTimer {
    _gcdTimer = [self createGCDTimer];
    dispatch_source_set_event_handler(_gcdTimer, ^{
        self->_secondCount --;
        //防止出现负数的情况
        if (self->_secondCount<0) {
            self->_secondCount = 0;
        }
        [self setSpecViewTextWithSeconds:self->_secondCount];
    });
    // 启动定时器
    dispatch_resume(_gcdTimer);
}
- (void)funcButtonClick {
    if ([_tool haveRecord]) {
        //有录音
        if ([_tool isPlayingRecord]) {
            //正在播放的话，就暂停
            [_tool pausePlaying];
            dispatch_suspend(_gcdTimer);
            [self.funcBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
        } else {
            if (_secondCount < _voiceLength) {
                //播放暂停了，点击继续播放
                [_tool continuePlaying];
                dispatch_resume(_gcdTimer);
                [self.funcBtn setImage:[UIImage imageNamed:@"record_pause"] forState:UIControlStateNormal];
            } else {
                //从头开始播放
                [_tool playLastestRecord];
                [self addPlayGCDTimer];
                [self.funcBtn setImage:[UIImage imageNamed:@"record_pause"] forState:UIControlStateNormal];
            }
        }
    } else {
        //没有录音就开始录音
        if (!_gcdTimer && _secondCount == 0) {
            [self addSpectrumView];
            [self.tool beginRecordVoice];
            [self addRecordGCDTimer];
            [self.funcBtn setImage:[UIImage imageNamed:@"record_pause"] forState:UIControlStateNormal];
        } else if (_gcdTimer) {
            //结束录音
            [self manualEndRecord];
        }
    }
}
- (void)manualEndRecord {
    [_tool endRecordVoice];
    //取消计时
    dispatch_cancel(_gcdTimer);
    _voiceLength = _secondCount;
    if (!self.tipLb.hidden) {
        self.tipLb.hidden = YES;
    }
    [self.funcBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
    self.btnBgView.hidden = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //此方法拦截了事件，让当前view成为了响应者。
}

#pragma mark ==== JZAudioToolDelegate ====
- (void)recordVoiceFinishPlay {
    dispatch_cancel(_gcdTimer);
    [self.funcBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
    [self setSpecViewTextWithSeconds:_voiceLength];
    _secondCount = _voiceLength;
}

@end








