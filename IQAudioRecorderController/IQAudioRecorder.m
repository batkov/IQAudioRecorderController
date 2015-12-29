//
//  IQAudioRecorder.m
//  IQAudioRecorderController Demo
//
//  Created by Sebastian Ludwig on 09.07.15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

#import "IQAudioRecorder.h"

@interface IQAudioRecorder () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@end

@implementation IQAudioRecorder
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    
    BOOL recordingIsPrepared;
    
    NSString *oldSessionCategory;
}

- (instancetype) initWithDelegate:(id<IQAudioRecorderDelegate>) delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        // Unique recording URL
        NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
        _filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", fileName]];
        
        oldSessionCategory = [[AVAudioSession sharedInstance] category];
        
        // Define the recorder setting
        {
            NSDictionary *delegateRecordSettings = [_delegate recordSettingsForAudioRecorder:self];
            NSDictionary *recordSetting = delegateRecordSettings ? : @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                                                       AVSampleRateKey: @(44100.0),
                                                                       AVNumberOfChannelsKey: @(2)};
            NSError * error;
            // Initiate and prepare the recorder
            audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_filePath]
                                                        settings:recordSetting
                                                           error:&error];
            audioRecorder.delegate = self;
            if (error) {
                [self.delegate audioRecorder:self didFailWithError:error];
            }
            audioRecorder.meteringEnabled = YES;
        }
        
        [self requestForMicPermission];
    }
    return self;
}

- (void)dealloc
{
    [audioRecorder stop];
    audioRecorder.delegate = nil;
    [audioPlayer stop];
    audioPlayer.delegate = nil;
    
    [[AVAudioSession sharedInstance] setCategory:oldSessionCategory error:nil];
}

- (void) requestForMicPermission {
    __weak typeof(self) selff = self;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            [selff.delegate microphoneAccessDeniedForAudioRecorder:selff];
        }
    }];
    
}

- (CGFloat)updateMeters
{
    if (audioRecorder.isRecording) {
        [audioRecorder updateMeters];
        
        CGFloat normalizedValue = pow(10, [audioRecorder averagePowerForChannel:0] / 20);
        return normalizedValue;
    }
    else if (audioPlayer.isPlaying) {
        [audioPlayer updateMeters];
        
        CGFloat normalizedValue = pow(10, [audioPlayer averagePowerForChannel:0] / 20);
        return normalizedValue;
    }
    return 0;
}

- (NSTimeInterval)currentTime
{
    if (self.isRecording) {
        return audioRecorder.currentTime;
    }
    
    return audioPlayer.currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    if (!self.isRecording) {
        audioPlayer.currentTime = currentTime;
    }
}

#pragma mark Recording

// HINT: at the moment this overwrites the current recording -> create new recorder with different URL?
// HINT: this method is likely (and should) to be called on a background thread -> ensure thread safety
- (void)prepareForRecording
{
    NSError * error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (error) {
        [self.delegate audioRecorder:self didFailWithError:error];
    }
    
    [audioRecorder prepareToRecord];
    recordingIsPrepared = YES;
}

- (void)startRecording
{
    if (!recordingIsPrepared) {
        [self prepareForRecording];
    }
    NSTimeInterval duration = [self.delegate recordDurationForAudioRecorder:self];
    if (duration <= 0) {
        [audioRecorder record];
    } else {
        [audioRecorder recordForDuration:duration];
    }
    recordingIsPrepared = NO;
}

- (void)stopRecording
{
    [audioRecorder stop];
}

- (void)discardRecording
{
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    [self prepareForRecording];
}

- (BOOL)isRecording
{
    return audioRecorder.isRecording;
}

#pragma mark Playback

- (NSTimeInterval)playbackDuration
{
    return audioPlayer.duration;
}

- (void)startPlayback
{
    NSError * error;
    // TODO: prevent playback while recording is running and vice versa
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        [self.delegate audioRecorder:self didFailWithError:error];
    }
    recordingIsPrepared = NO;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.filePath]
                                                         error:&error];
    if (error) {
        [self.delegate audioRecorder:self didFailWithError:error];
    }
    audioPlayer.delegate = self;
    audioPlayer.meteringEnabled = YES;
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

- (void)stopPlayback
{
    [audioPlayer stop];
}

- (void)pausePlayback
{
    [audioPlayer pause];
}

- (void)resumePlayback
{
    [audioPlayer play];
}

- (BOOL)isPlaying
{
    return audioPlayer.isPlaying;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate audioRecorder:self didFinishPlaybackSuccessfully:flag];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.delegate audioRecorder:self didFailWithError:error];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.delegate audioRecorder:self didFinishRecordingSuccessfully:flag];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [self.delegate audioRecorder:self didFailWithError:error];
}


@end
