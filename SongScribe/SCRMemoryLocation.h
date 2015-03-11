//
//  SCRMemoryLocation.h
//  SongScribe
//
//  Created by Thomas Fritchman on 10/9/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>

@interface SCRMemoryLocation : NSObject

@property (atomic) CMTime location;
//@property (atomic) NSDate* buttonPressTime;
@property (atomic) CMTime locationAtButtonPress;

@end
