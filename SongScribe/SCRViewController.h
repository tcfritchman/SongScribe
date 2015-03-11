//
//  SCRViewController.h
//  SongScribe
//
//  Created by Thomas Fritchman on 8/25/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRWaveformView.h"
#import "SCRPositionSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#include <AVFoundation/AVFoundation.h>

@interface SCRViewController : UIViewController <MPMediaPickerControllerDelegate>
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) AVAsset *mediaAsset;
@property (nonatomic) float playbackRate;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet SCRWaveformView *waveformView;
@property (weak, nonatomic) IBOutlet SCRPositionSlider *positionSlider;
@property (weak, nonatomic) IBOutlet UILabel *slowSwitch;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waveformLoading;

- (IBAction)PlayTapped:(id)sender;
- (IBAction)loadTapped:(id)sender;
- (IBAction)slowSwitched:(id)sender;
- (IBAction)Seek:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)memoryButtonDown1:(id)sender;
- (IBAction)memoryButtonUp1:(id)sender;
- (IBAction)memoryButtonHeld1:(id)sender;
- (IBAction)memoryButtonDown2:(id)sender;
- (IBAction)memoryButtonUp2:(id)sender;
- (IBAction)memoryButtonHeld2:(id)sender;

@end
