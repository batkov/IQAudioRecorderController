//
//  IQAudioRecorderController.h
// https://github.com/hackiftekhar/IQAudioRecorderController
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

#import "SCSiriWaveformView.h"

@class IQAudioRecorderController;

@protocol IQAudioRecorderControllerDelegate <NSObject>

@optional
- (void)audioRecorderController:(IQAudioRecorderController *)controller didFinishWithAudioAtPath:(NSString *)filePath;
- (void)audioRecorderControllerDidCancel:(IQAudioRecorderController *)controller;

// Error Handling
- (void)audioRecorderController:(IQAudioRecorderController *)controller didFailWithError:(NSError *)error;
- (void)microphoneAccessDeniedForAudioRecorderController:(IQAudioRecorderController *)controller;

// Advanced Record control
- (NSDictionary *) recordSettingsForAudioRecorderController:(IQAudioRecorderController *)controller;
- (NSTimeInterval) recordDurationForAudioRecorderController:(IQAudioRecorderController *)controller; // <= 0 will start endless record
@end


@interface IQAudioRecorderController : UIViewController

@property (nonatomic, weak) IBOutlet id<IQAudioRecorderControllerDelegate> delegate;

@property (nonatomic) IBInspectable UIColor *normalTintColor;
@property (nonatomic) IBInspectable UIColor *recordingTintColor;
@property (nonatomic) IBInspectable UIColor *playingTintColor;
@property (nonatomic) IBInspectable UIColor *backgroundColor;

// Toolbar
@property (nonatomic) UIBarButtonItem *playButton;
@property (nonatomic) UIBarButtonItem *pauseButton;
@property (nonatomic) UIBarButtonItem *recordButton;
@property (nonatomic) UIBarButtonItem *trashButton;

@property (nonatomic, copy) NSArray *recordToolbarItems;
@property (nonatomic, copy) NSArray *playToolbarItems;

@property(nonatomic, assign) BOOL shouldShowRemainingTime;

+ (UINavigationController *)embeddedIQAudioRecorderControllerWithDelegate:(id<IQAudioRecorderControllerDelegate, UINavigationControllerDelegate>)delegate;

@end
