//
//  SCRPositionSlider.m
//  SongScribe
//
//  Created by Thomas Fritchman on 8/27/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import "SCRPositionSlider.h"

@implementation SCRPositionSlider

float yOffset = 15.0;
float handleWidth = 20.0;
float handleHeight = 25.0;
float viewWidth;
float viewHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPosition:0.0];
        [self setIsTracking:false];
        viewWidth = self.bounds.size.width;
        viewHeight = self.bounds.size.width;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setPosition:0.0];
        [self setIsTracking:false];
        viewWidth = self.bounds.size.width;
        viewHeight = self.bounds.size.width;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self == nil)
        return;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawHandle:context];
}

- (void)drawHandle:(CGContextRef)context {
    float topCornerX = self.position * (viewWidth - handleWidth);
    CGContextSaveGState(context);
    
    [[UIColor grayColor] set];
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, topCornerX, yOffset);
    CGContextAddLineToPoint(context, topCornerX + handleWidth, yOffset);
    CGContextAddLineToPoint(context, topCornerX + (handleWidth / 2), yOffset + handleHeight);
    CGContextClosePath(context);
    CGContextSetGrayFillColor(context, 0.5, 0.5);
    CGContextSetGrayStrokeColor(context, 0.5, 0.5);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

- (void)moveHandle:(CGPoint) point {
    self.position = (point.x / viewWidth);
    if (self.position < 0.0)
        self.position = 0.0;
    else if (self.position > 1.0)
        self.position = 1.0;
    
    //NSLog(@"%f - %f", point.x, self.position);
    [self setNeedsDisplay];
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self setIsTracking:true];
    NSLog(@"TRACKING");
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //We need to track continuously
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];

    // Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    [self moveHandle:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [self setIsTracking:false];
    NSLog(@"NOT TRACKING");
}

-(void)updatePosition:(float)pos {
    if (self.isTracking) return;
    self.position = pos;
    [self setNeedsDisplay];
}

@end
