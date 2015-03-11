//
//  SCRViewController.m
//  SongScribe
//
//  Created by Thomas Fritchman on 8/25/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import "SCRViewController.h"
#include <AVFoundation/AVFoundation.h>
#include "SCRMemoryLocation.h"

#define kPlaybackFileLocation CFSTR("/Volumes/Untitled/Users/tcfritchman/Music/AC-DC/Flick Of The Switch/01 Rising Power.m4a")

@interface SCRViewController ()
@end

@implementation SCRViewController

NSTimer *sliderUpdateTimer;
SCRMemoryLocation *memoryLocations[4];

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playbackRate = 1.0;
    [self buildMemoryLocationsArray];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildMemoryLocationsArray {
    for (int i=0;i<4;i++) {
        memoryLocations[i] = [[SCRMemoryLocation alloc]init];
    }
}

-(IBAction)PlayTapped:(id)sender {
    NSLog(@"playtapped");
    if (!self.player) {
        NSLog(@"NO PLAYER!");
        return;
    }
    
    if (self.player.rate > 0.0) {
        NSLog(@"PAUSE!");
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.player setRate:0.0];
        
    } else {
        NSLog(@"PLAY!");
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self.player setRate:self.playbackRate];
    }
}

- (IBAction)loadTapped:(id)sender {
    // Retrieve audio file from Media Picker
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    picker.prompt = NSLocalizedString(@"Choose song", "prompt in media picker");
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)slowSwitched:(id)sender {
    if (self.player.rate > 0.0) {
        if ([sender isOn])
            self.playbackRate = 0.6;
        else
            self.playbackRate = 1.0;
        [self.player setRate:self.playbackRate];
    }
}

- (IBAction)Seek:(id)sender {
    //self.player.currentTime = self.player.duration * self.positionSlider.position;
    [self.player seekToTime:(CMTimeMultiplyByFloat64(self.player.currentItem.asset.duration, (Float64)self.positionSlider.position))];
}

- (IBAction)volumeChanged:(id)sender {
    self.player.volume = self.volumeSlider.value;
}

- (IBAction)memoryButtonDown1:(id)sender {
    [self memoryButtonDown:0];
}

- (IBAction)memoryButtonUp1:(id)sender {
    [self memoryButtonUp:0];
}

- (IBAction)memoryButtonHeld1:(id)sender {
    [self memoryButtonHeld:0];
}

- (IBAction)memoryButtonDown2:(id)sender {
    [self memoryButtonDown:1];
}

- (IBAction)memoryButtonUp2:(id)sender {
    [self memoryButtonUp:1];
}

- (IBAction)memoryButtonHeld2:(id)sender {
    [self memoryButtonHeld:1];
}

- (void)memoryButtonDown:(int)i {
    NSLog(@"Memory Button DOWN!");
    if (self.player) {
        memoryLocations[i].locationAtButtonPress = [self.player currentTime];
    }
}

- (void)memoryButtonUp:(int)i {
    NSLog(@"Memory Button UP!");
    if (self.player) {
        @try {
            [self.player seekToTime:memoryLocations[i].location];
        }
        @catch (NSException *exception) {
            NSLog(@"Couldn't seek %@", exception.name);
            NSLog(@"because %@", exception.reason);
        }
    }
}

- (void)memoryButtonHeld:(int)i {
    NSLog(@"Memory Button HELD!");
    if (self.player) {
        memoryLocations[i].location = memoryLocations[i].locationAtButtonPress;
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self.waveformLoading startAnimating];
    [self preLoadCleanup];
    [self dismissViewControllerAnimated: YES completion:^(void) {
        [self loadNewSongWithMediaItemCollection:mediaItemCollection];
    }];
    
    //[self loadNewSongWithMediaItemCollection:mediaItemCollection];
}

-(void)preLoadCleanup {
    // Clean up EVERYTHING for loading a new song
    // IMPORTANT: IF LOADING A 2ND SONG... DOES FIRST PLAYER GET DESTROYED?
    if (self.player) {
        NSLog(@"PAUSE!");
        [self.player pause];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        [self buildMemoryLocationsArray];
    }
}


-(void)loadNewSongWithMediaItemCollection:(MPMediaItemCollection *)collection {
    if (collection) {
        // extract url from selected MPMediaItem
        MPMediaItem *mediaItem = (MPMediaItem *)[collection.items objectAtIndex:0];
        NSURL *mediaItemURL = [mediaItem valueForProperty: MPMediaItemPropertyAssetURL];
        //NSString *URL = [mediaItemURL absoluteString];
        
        // Create an AVAsset with URL
        self.mediaAsset = [[AVURLAsset alloc] initWithURL:mediaItemURL options:nil];
        
        // prepare controls
        //[self.waveformView updateAudioClip:URL];
        [self.waveformView updateAudioClip:self.mediaAsset];
        //[self createAudioPlayerWithFile:URL];
        //[self creatAudioPlayerWithUrl:mediaItemURL];
        [self createPlayer];
        [self createTimerForUpdatingSlider];
        [self.waveformLoading stopAnimating];
    }
}

-(void)createPlayer {
    
    self.playerItem = [[AVPlayerItem alloc]initWithAsset:self.mediaAsset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    
    self.player.volume = 0.5;
}

/*
-(void)creatAudioPlayerWithUrl:(NSURL*)url {
    NSError* err;
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&err];
    if (err != noErr) {
        NSLog(@"Error allocating AVAudioPlayer");
    }
    self.player.volume = 0.5;
    self.player.enableRate = YES;
    [self.player setNumberOfLoops: -1];
    self.player.rate = 1.0;
}
 */

/*
-(void)createAudioPlayerWithFile:(NSString*)path {
    NSError* err;
    NSURL *url = (__bridge NSURL *)(CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false));
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&err];
    if (err != noErr) {
        //NSLog(@"Error allocating AVAudioPlayer");
    }
    self.player.volume = 0.5;
    self.player.enableRate = YES;
    [self.player setNumberOfLoops: -1];
    self.player.rate = 1.0;
    
}
 */

-(void)createTimerForUpdatingSlider {
    sliderUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)0.1
                                                         target:self
                                                       selector:@selector(updateSliderPosition:)
                                                       userInfo:nil
                                                        repeats:true];
}

-(void)updateSliderPosition:(NSTimer*)timer {
    if (self.player == nil || CMTimeGetSeconds(self.player.currentItem.asset.duration) == 0.0) {
        [self.positionSlider updatePosition:0.0];
    } else {
        [self.positionSlider updatePosition:(CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.asset.duration))];
    }
}

@end
