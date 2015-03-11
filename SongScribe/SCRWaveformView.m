//
//  SCRWaveformView.m
//  WaveformView
//
//  Created by Thomas Fritchman on 8/24/14.
//  Copyright (c) 2014 tcfritchman. All rights reserved.
//

#import "SCRWaveformView.h"
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>

#define kPlaybackFileLocation CFSTR("/Volumes/Untitled/Users/tcfritchman/Music/AC-DC/Flick Of The Switch/01 Rising Power.m4a")

@implementation SCRWaveformView

static Float32 *sampleArray = NULL;
static int sampleArraySize;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Make sure there are audio samples to read from
    if (sampleArray == NULL)
        return;
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawWaveform:context width:self.bounds.size.width height:self.bounds.size.height fromSamples:sampleArray ofCount:sampleArraySize];
    [self drawWaveform2:context width:self.bounds.size.width height:self.bounds.size.height fromSamples:sampleArray ofCount:sampleArraySize];
}

- (void)drawWaveform:(CGContextRef)context
               width:(int)width
               height:(int)height
         fromSamples:(Float32 *)sampleArray
             ofCount:(int)sampleCount {
    // Function Constants:
    float center = (float)height / 2.0;
    static int pixelsPerSample = 1;
    float yScaleFactor = center;
    int numberSamples = width / pixelsPerSample;
    
    CGContextSaveGState(context);
    
    // Set context color
    [[UIColor grayColor] set];
    
    // Draw waveform
    int dataIndex = 0;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, center);
    
    for (int i=0; i<numberSamples; i++) {
        // Get sample data and scale it
        dataIndex = (int)(((float)i / (float)numberSamples) * (float)sampleArraySize);
        float scaledSample = yScaleFactor * sampleArray[dataIndex];
        
        // TEST!
        //NSLog(@"Draw: %f, %d", sampleArray[dataIndex], dataIndex);
        
        // Draw the point
        CGContextAddLineToPoint(context, (float)i, center - scaledSample);
        //NSLog(@"printing sample %d", dataIndex);
    }
    
    CGContextAddLineToPoint(context, numberSamples, center);
    CGContextClosePath(context);
    CGContextSetGrayFillColor(context, 0.1f, 0.85f);
    CGContextSetGrayStrokeColor(context, 0.0, 0.0);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    //NSLog(@"Waveform done");
}

//TODO: GET RID OF THIS CRAPPY QUICK FIX!   
- (void)drawWaveform2:(CGContextRef)context
               width:(int)width
               height:(int)height
         fromSamples:(Float32 *)sampleArray
             ofCount:(int)sampleCount {
    // Function Constants:
    float center = (float)height / 2.0;
    static int pixelsPerSample = 1;
    float yScaleFactor = center;
    int numberSamples = width / pixelsPerSample;
    
    CGContextSaveGState(context);
    
    // Set context color
    [[UIColor grayColor] set];
    
    // Draw waveform
    int dataIndex = 0;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, center);
    
    for (int i=0; i<numberSamples; i++) {
        // Get sample data and scale it
        dataIndex = (int)(((float)i / (float)numberSamples) * (float)sampleArraySize);
        float scaledSample = yScaleFactor * sampleArray[dataIndex];
        // Draw the point
        CGContextAddLineToPoint(context, (float)i, center + scaledSample);
        //NSLog(@"printing sample %d", dataIndex);
    }
    
    CGContextAddLineToPoint(context, numberSamples, center);
    CGContextClosePath(context);
    CGContextSetGrayFillColor(context, 0.1f, 0.85f);
    CGContextSetGrayStrokeColor(context, 0.0, 0.0);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    //NSLog(@"Waveform done");
}

- (void)getAudioDataFromAsset:(AVAsset*)asset
                outArray:(Float32**)dataSampleArray
                  ofSize:(int*)dataSampleArraySize {
    
    //const int RING_BUFFER_SIZE = 1024;
    
    AVAssetTrack *assetTrack = asset.tracks[0];
    
    // do i need this???
    NSError *error = [NSError alloc];
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    //AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderOutput alloc];
    //[assetReader addOutput:assetReaderOutput];
    
    // output settings dict
    NSDictionary *trackOutputSettings = @{
                                          @"AVFormatIDKey" : [NSNumber numberWithInt:kAudioFormatLinearPCM],
                                          @"AVSampleRateKey" : [NSNumber numberWithFloat:44100],
                                          @"AVNumberOfChannelsKey" : [NSNumber numberWithInt:1],
                                          @"AVLinearPCMBitDepthKey" : [NSNumber numberWithInt:32],
                                          @"AVLinearPCMIsBigEndianKey" : [NSNumber numberWithBool:false],
                                          @"AVLinearPCMIsFloatKey" : [NSNumber numberWithBool:true]
                                          };
    
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:assetTrack outputSettings:trackOutputSettings];
    
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    
    // Read buffer
    // Ring buffer??
    // Assumes 32-bit float mono
    /*
    typedef struct {
        Float32 data[RING_BUFFER_SIZE];
        UInt16 readIdx;
        UInt16 writeIdx;
    } InBuffer;
     */
    
    //InBuffer *localBuffer;
    
    size_t lengthAtOffset = 0;
    size_t totalLength = 0;
    CMSampleBufferRef nextBuffer;
    CMBlockBufferRef buffer;
    char *data;
    //double *dataSampleArray;
    int i = 0;
    int j = 0;
    int k = 0;
    Float32 currentMax = 0;
    
    // TODO: MAKE ME MORE EFFICIENT!
    *dataSampleArray = (Float32*)malloc(sizeof(Float32)*4000000);
    
    while (1) {
        nextBuffer = [trackOutput copyNextSampleBuffer];
        
        if (nextBuffer == NULL) return;
        
        buffer = CMSampleBufferGetDataBuffer(nextBuffer);
        
        if (CMBlockBufferGetDataPointer(buffer, 0, &lengthAtOffset, &totalLength, &data) != noErr) {
            NSLog(@"Error getting data buffer from asset");
            return;
        }
        
        // copy sample buffer into local buffer
        //memcpy((void*)&data, (void*)localBuffer->data, totalLenth);
        Float32 *floatData = (Float32*)data;
        //NSLog(@"%f, length:%zu", floatData[0], totalLength);
        
        // copy data to sample array for later use
        lengthAtOffset /= sizeof(Float32);
        for (i=0; i<lengthAtOffset; i++) {
            // Choose the max out of every 50 samples and put into array
            //TODO minimize array size...
            if (k == 0) {
                currentMax = (Float32)floatData[i];
                k++;
            } else if (k == 49) {
                (*dataSampleArray)[j] = currentMax;
                
                // Test
                //printf("Initialize: %f,%d\n", (*dataSampleArray)[j],j);
                
                j++;
                k = 0;
            } else {
                if (fabs(floatData[i]) > currentMax) {
                    currentMax = fabs((Float32)floatData[i]);
                }
                k++;
            }
        }
        *dataSampleArraySize = j;
    }
}

- (void)getAudioDataFromPath:(CFStringRef)path
                outArray:(double **)dataSampleArray
                  ofSize:(int*)dataSampleArraySize {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    ExtAudioFileRef eaf;
    OSStatus err = ExtAudioFileOpenURL(url, &eaf);
    if(err != noErr) {
        NSLog(@"Could not open file");
        [self CheckError:err];
        return;
    } else NSLog(@"File opened successfully");
    
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = 44100;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kLinearPCMFormatFlagIsFloat;
    asbd.mBitsPerChannel = sizeof(Float32) * 8;
    asbd.mChannelsPerFrame = 1;
    asbd.mBytesPerFrame = asbd.mChannelsPerFrame * sizeof(Float32); // one sample per frame
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerPacket = asbd.mFramesPerPacket * asbd.mBytesPerFrame;
    
    err = ExtAudioFileSetProperty(eaf, kExtAudioFileProperty_ClientDataFormat, sizeof(asbd), &asbd);
    if (err != noErr) {
        NSLog(@"Error setting file property: client data format");
        [self CheckError:err];
        return;
    }

    // Read file contents using ExtAudioFileRead
    int numberSamples = 1024; // Number of samples per buffer
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    UInt32 outputBufferSize = numberSamples * asbd.mBytesPerPacket;
    
    UInt8 *outputBuffer = (UInt8 *) malloc(sizeof(UInt8*) *outputBufferSize);
    
    bufferList.mBuffers[0].mNumberChannels = asbd.mChannelsPerFrame;
    bufferList.mBuffers[0].mDataByteSize = outputBufferSize;
    bufferList.mBuffers[0].mData = outputBuffer;
    
    UInt32 numberFrames = numberSamples;
    float *bufferSampleArray;
    //double dataSampleArray[1000000];
    *dataSampleArray = (double *)malloc(sizeof(double) * 1000000);
    int j = 0;
    int k = 0;
    double currentMax = 0.0;
    
    while (numberFrames > 0) {
        err = ExtAudioFileRead(eaf, &numberFrames, &bufferList);
        
        if (err != noErr) {
            NSLog(@"Error reading file");
            [self CheckError:err];
            return;
        }
        
        AudioBuffer audioBuffer = bufferList.mBuffers[0];
        bufferSampleArray = (float*)audioBuffer.mData;
        
        for (int i=0; i<numberSamples; i++) {
            // Choose the max out of every 50 samples and put into array
            //TODO minimize array size...
            if (k == 0) {
                currentMax = (double)bufferSampleArray[i];
                k++;
            } else if (k == 49) {
                (*dataSampleArray)[j] = currentMax;
                // Test
                //printf("%f,%d\n", (*dataSampleArray)[j],j);
                j++;
                k = 0;
            } else {
                if (fabs((double)bufferSampleArray[i]) > currentMax) {
                    currentMax = fabs((double)bufferSampleArray[i]);
                }
                k++;
            }
        }
    }
    *dataSampleArraySize = j;
}

- (void)CheckError:(OSStatus) error {
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\''; errorString[6] = '\0';
    } else {
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    }
    NSLog(@"Error: %s\n", errorString);
}

/*
-(void)updateAudioClip:(NSString*)path {
    //[self getAudioDataFrom:(CFStringRef)path outArray:&sampleArray ofSize:&sampleArraySize];
    [self getAudioDataFromAsset:<#(AVAsset *)#> outArray:<#(double **)#> ofSize:<#(int *)#>]
    [self setNeedsDisplay];
}
 */

-(void)updateAudioClip:(AVAsset*)asset {
    [self getAudioDataFromAsset:asset outArray:&sampleArray ofSize:&sampleArraySize];
    [self setNeedsDisplay];
}

@end
