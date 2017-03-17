//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface UUAVAudioPlayer ()<AVAudioPlayerDelegate> {

    NSString *_filePath;
}

@end

@implementation UUAVAudioPlayer

+ (UUAVAudioPlayer *)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });    
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl
{
    _filePath = songUrl;
    dispatch_async(dispatch_queue_create("playSoundFromUrl", NULL), ^{
        if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerBeiginLoadVoice)]) {
            [self.delegate UUAVAudioPlayerBeiginLoadVoice];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:songUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playSoundWithData:data];
        });
    });
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)playSongWithData:(NSData *)songData
{
    [self setupPlaySound];
    [self playSoundWithData:songData];
}

-(void)playSoundWithData:(NSData *)soundData{
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:soundData error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        
        NSLog(@"文件已损坏，请重新下载");
        NSError *error = nil;
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:_filePath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:_filePath error:&error];
            if(error) {
                
                NSLog(@"删除损坏文件失败：%@",error);
            }
        }
        if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerFailToPlay)]) {
            [self.delegate UUAVAudioPlayerFailToPlay];
        }
        NSLog(@"ERror creating player: %@", [playerError description]);
        return;
    }
    _player.delegate = self;
    [_player play];
    if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerBeiginPlay)]) {
        [self.delegate UUAVAudioPlayerBeiginPlay];
    }
}

-(void)setupPlaySound{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(UUAVAudioPlayerDidFinishPlay)]) {
        [self.delegate UUAVAudioPlayerDidFinishPlay];
    }
}

- (void)stopSound
{
    if (_player && _player.isPlaying) {
        [_player stop];
    }
}

//- (void)applicationWillResignActive:(UIApplication *)application{
//    [self.delegate UUAVAudioPlayerDidFinishPlay];
//}

- (BOOL)audioIsPlaying {

    return [_player isPlaying];
}

@end
