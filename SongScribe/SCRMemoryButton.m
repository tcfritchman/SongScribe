//
//  SCRMemoryButton.m
//  SongScribe
//
//  Created by Thomas Fritchman on 10/7/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import "SCRMemoryButton.h"

@implementation SCRMemoryButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.color = [[UIColor alloc]initWithRed:0.5 green:0.5 blue:0.5 alpha:0.0]; // default color
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set color depending on whether highlighted
    

    // Draw a rectangle (for now)
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    
}

@end
