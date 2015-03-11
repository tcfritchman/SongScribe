//
//  SCRWaveformView.h
//  WaveformView
//
//  Created by Thomas Fritchman on 8/24/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

@interface SCRWaveformView : UIView

//-(void)updateAudioClip:(NSString*)path;
-(void)updateAudioClip:(AVAsset*)asset;

@end
