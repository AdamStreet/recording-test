//
//  ASRecorder.h
//  RecorderTest
//
//  Created by Adam Szabo on 24/10/2016.
//  Copyright © 2016 Adam Szabo. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSUInteger ASAudioRecorderNumberOfChannels = 2;

@interface ASRecorder : NSObject

@property (nonatomic, readonly) BOOL isRecording;

+ (void)requestRecordPermission:(void (^)(BOOL granted))completion;

- (id)initWithURL:(NSURL*)fileURL;

- (BOOL)startRecording:(NSError* __autoreleasing *)error;
- (void)pauseRecording;
- (void)stopRecording;

- (void)cancel;

- (BOOL)getAudioLevels:(Float32 *)levels
			peakLevels:(Float32 *)peakLevels;

@end
