//
//  ASRecorder.m
//  RecorderTest
//
//  Created by Adam Szabo on 24/10/2016.
//  Copyright © 2016 Adam Szabo. All rights reserved.
//

#import "ASRecorder.h"

#import <AVFoundation/AVFoundation.h>

@interface ASRecorder ()

@property (nonatomic, readwrite, copy) NSURL* audioFileURL;

@property (nonatomic) AVAudioRecorder *recorder;

@end


@implementation ASRecorder

#pragma mark - Initialization

- (id)initWithURL:(NSURL*)fileURL
{
	NSParameterAssert(fileURL);
	
	if (self = [super init]) {
		self.audioFileURL = fileURL;
	}
	
	return self;
}

- (void)dealloc
{
	self.recorder.delegate = nil;
	[self stopRecording];
}

#pragma mark - Private methods

- (BOOL)setupRecording:(NSError * __autoreleasing *)error
{
	AVAudioSession *session = [[self class] audioSession];
	
	if (!session.isInputAvailable)
		return NO;
	
	NSError *internalError = nil;
	if ([session setCategory:AVAudioSessionCategoryPlayAndRecord
					   error:&internalError]) {
		
		if ([session setActive:YES
						 error:&internalError]){
			
			// Initiate and prepare the recorder
			
			self.recorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileURL
														settings:[[self class] recorderSetting]
														   error:&internalError];
			
			if (error) {
				*error = [internalError copy];
			}
			
			NSAssert1(self.recorder, @"Error while setting up recorder: %@", internalError);
			
			//	self.recorder.delegate = self;
			if (![self.recorder prepareToRecord]) {
				self.recorder = nil;
			}
		}
	}
	
	return !!self.recorder;
}

- (void)startRecording
{
	[self.recorder record];
}

- (void)enableLevelMetering
{
	self.recorder.meteringEnabled = YES;
}

#pragma mark Accessors

#pragma mark Class methods

+ (NSDictionary *)recorderSetting
{
	static NSDictionary *_recordSetting = nil;
	if (!_recordSetting) {
		// Define the recorder setting
		NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
		
		// Set format
		recordSetting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
		
		// All format keys
		recordSetting[AVSampleRateKey] = @(44100.0);
		recordSetting[AVNumberOfChannelsKey] = @(ASAudioRecorderNumberOfChannels);
		
		// LinearPCM keys
		recordSetting[AVLinearPCMIsBigEndianKey] = @NO;
		recordSetting[AVLinearPCMBitDepthKey] = @16;
		recordSetting[AVLinearPCMIsNonInterleaved] = @NO;
		recordSetting[AVLinearPCMIsFloatKey] = @NO;
		
		_recordSetting = [recordSetting copy];
	}
	
	return _recordSetting;
}

+ (AVAudioSession *)audioSession
{
	return [AVAudioSession sharedInstance];
}

#pragma mark - Public methods

- (BOOL)startRecording:(NSError* __autoreleasing *)error
{
	NSLog(@"Recording");
	
	const BOOL success = [self setupRecording:error];
	if (success) {
		[self enableLevelMetering];
		[self startRecording];
	}
	
	return success;
}

- (void)pauseRecording
{
	[self.recorder pause];
}

- (void)stopRecording
{
	NSLog(@"Stopping");
	
	[self.recorder stop];
}

- (void)cancel
{
	[self stopRecording];
	
	[self.recorder deleteRecording];
}

// gets audio levels from the audio queue object
- (BOOL)getAudioLevels:(Float32 *)levels
			peakLevels:(Float32 *)peakLevels
{
	if (![self isRecording])
		return NO;
	
	[self.recorder updateMeters];
	
	static const CGFloat kSilenceDBValue = -160.0;	// based on the documentation of -[AVAudioRecorder averagePowerForChannel]
	
	for (NSUInteger i = 0; i < ASAudioRecorderNumberOfChannels; ++i) {
		const CGFloat averageLevel = (CGFloat)[self.recorder averagePowerForChannel:i];
		const CGFloat peakLevel = (CGFloat)[self.recorder peakPowerForChannel:i];
		
		NSAssert1(kSilenceDBValue <= averageLevel && averageLevel <= 0.0, @"Average level has invalid value: %@", @(averageLevel));
		NSAssert1(kSilenceDBValue <= peakLevel && peakLevel <= 0.0, @"Peak level has invalid value: %@", @(peakLevel));
		
		// set values between 0.0 & 1.0
		// Note: kSilenceDBValue is a negative value
		levels[i] = ((averageLevel - kSilenceDBValue) / -kSilenceDBValue);
		peakLevels[i] = ((peakLevel - kSilenceDBValue) / -kSilenceDBValue);
	}
	
	return YES;
}

#pragma mark Accessors

- (BOOL)isRecording
{
	return self.recorder.isRecording;
}

#pragma mark Class methods

+ (void)requestRecordPermission:(void (^)(BOOL granted))completion
{
	[[[self class] audioSession] requestRecordPermission:^(BOOL granted) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) {
				completion(granted);
			}
		});
	}];
}

@end
