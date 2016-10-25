//
//  ViewController.m
//  RecorderTest
//
//  Created by Adam Szabo on 24/10/2016.
//  Copyright © 2016 Adam Szabo. All rights reserved.
//

#import "ViewController.h"

#import "ASRecorder.h"

@interface ViewController ()

@property (nonatomic) ASRecorder *recorder;
@property (nonatomic) NSTimer *visualUpdateTimer;

@end

@implementation ViewController

#pragma mark - Initialization
#pragma mark - Private methods

- (NSURL *)testAudioURL
{
	static NSString * const filename = @"test_audio.caf";
	
	NSURL *cacheDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
																 inDomains:NSUserDomainMask] firstObject];
	
	return [cacheDirURL URLByAppendingPathComponent:filename];
}

- (void)startVisualUpdater
{
	self.visualUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 30.0)	// Keep 30.0 FPS
															 target:self
															selector:@selector(updateVisuals)
															userInfo:nil
															 repeats:YES];
}

- (void)startTestRecording
{
	self.recorder = [[ASRecorder alloc] initWithURL:[self testAudioURL]];
	
	[self.recorder startRecording:nil];
	
	[self startVisualUpdater];
}

- (void)updateVisuals
{
	Float32 audioLevels[ASAudioRecorderNumberOfChannels];
	Float32 peakLevels[ASAudioRecorderNumberOfChannels];
	
	[self.recorder getAudioLevels:audioLevels
					   peakLevels:peakLevels];
	
	// TODO Update visuals
	NSLog(@"Audio/Peak level = %.2f / %.2f",
		  audioLevels[0], peakLevels[0]);
}

#pragma mark Accessors

- (void)setVisualUpdateTimer:(NSTimer *)visualUpdateTimer
{
	[_visualUpdateTimer invalidate];
	
	_visualUpdateTimer = visualUpdateTimer;
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[ASRecorder requestRecordPermission:^(BOOL granted) {
		if (granted) {
			[self startTestRecording];
		}
	}];
}

#pragma mark - Public methods
#pragma mark Accessors
#pragma mark Overrides
#pragma mark - User interaction handlers
#pragma mark - Notification handlers
#pragma mark - KVO
#pragma mark - <>

@end
