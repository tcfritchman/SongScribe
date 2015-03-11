//
//  SCRPositionSlider.h
//  SongScribe
//
//  Created by Thomas Fritchman on 8/27/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRPositionSlider : UIControl
@property float position; // Float 0.0 - 1.0
@property BOOL isTracking;

-(void)updatePosition:(float)pos;

//-(void)setPosition:(float)position;
//-(float)position;
@end
