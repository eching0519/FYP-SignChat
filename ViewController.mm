// Copyright 2019 The MediaPipe Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ViewController.h"

#import "mediapipe/objc/MPPGraph.h"
#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPLayerRenderer.h"

#include "mediapipe/framework/formats/landmark.pb.h"

#import "PreviewViewController.h"
#import "MPP2SCN.h"
#import <XCTest/XCTest.h>




@interface ViewController () <MPPGraphDelegate, MPPInputSourceDelegate>

// The MediaPipe graph currently in use. Initialized in viewDidLoad, started in viewWillAppear: and
// sent video frames on _videoQueue.
@property(nonatomic) MPPGraph* mediapipeGraph;

@end

@implementation ViewController {
    /// Handles camera access via AVCaptureSession library.
    MPPCameraInputSource* _cameraSource;
    
    /// Inform the user when camera is unavailable.
    IBOutlet UILabel* _noCameraLabel;
    /// Display the camera preview frames.
    IBOutlet UIView* _liveView;
    
    /// Render frames in a layer.
    MPPLayerRenderer* _renderer;
    
    /// Process camera frames on this queue.
    dispatch_queue_t _videoQueue;
    
    // point value converter of mediapipe and SceneKit
    MPP2SCN *converter;
    
    // captured data when recording
    BOOL recording;
    NSMutableArray *scFrames;
    float min_x;
    float max_x;
    float min_y;
    float max_y;
    float max_z;
}

@synthesize meaning;

-(IBAction)startRecording:(id)sender {
    [self resetRecordedData];
    recording = YES;
}

-(IBAction)stopRecording:(id)sender {
    recording = NO;
}

-(IBAction)cancelRecording:(id)sender {
    [self resetRecordedData];
    recording = NO;
}

-(void) resetRecordedData {
    [scFrames removeAllObjects];
    min_x = 100;
    max_x = -100;
    min_y = 100;
    max_y = -100;
    max_z = -100;
}

-(IBAction)switchCamera:(id)sender {
    if(recording) {
        return;
    }
    
    if(_cameraSource.cameraPosition == AVCaptureDevicePositionFront) {
        _cameraSource.cameraPosition = AVCaptureDevicePositionBack;
        _renderer.mirrored = NO;
    } else {
        _cameraSource.cameraPosition = AVCaptureDevicePositionFront;
        _renderer.mirrored = YES;
    }
    
    [self startGraphAndCamera];
}

#pragma mark - Cleanup methods

- (void)dealloc {
    self.mediapipeGraph.delegate = nil;
    [self.mediapipeGraph cancel];
    // Ignore errors since we're cleaning up.
    [self.mediapipeGraph closeAllInputStreamsWithError:nil];
    [self.mediapipeGraph waitUntilDoneWithError:nil];
}

#pragma mark - MediaPipe graph methods

+ (MPPGraph*)loadGraphFromResource:(NSString*)resource {
    // Load the graph config resource.
    NSError* configLoadError = nil;
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    if (!resource || resource.length == 0) {
        return nil;
    }
    NSURL* graphURL = [bundle URLForResource:resource withExtension:@"binarypb"];
    NSData* data = [NSData dataWithContentsOfURL:graphURL options:0 error:&configLoadError];
    if (!data) {
        NSLog(@"Failed to load MediaPipe graph config: %@", configLoadError);
        return nil;
    }
    
    // Parse the graph config resource into mediapipe::CalculatorGraphConfig proto object.
    mediapipe::CalculatorGraphConfig config;
    config.ParseFromArray(data.bytes, data.length);
    
    // Create MediaPipe graph with mediapipe::CalculatorGraphConfig proto object.
    MPPGraph* newGraph = [[MPPGraph alloc] initWithGraphConfig:config];
    [newGraph addFrameOutputStream:kOutputStream outputPacketType:MPPPacketTypePixelBuffer];
    [newGraph addFrameOutputStream:kLandmarksOutputStream outputPacketType:MPPPacketTypeRaw];
    return newGraph;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    _renderer = [[MPPLayerRenderer alloc] init];
    _renderer.layer.frame = _liveView.layer.bounds;
    [_liveView.layer addSublayer:_renderer.layer];
    _renderer.frameScaleMode = MPPFrameScaleModeFillAndCrop;
    // When using the front camera, mirror the input for a more natural look.
    _renderer.mirrored = NO;
    
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(
                                                                                 DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, /*relative_priority=*/0);
    _videoQueue = dispatch_queue_create(kVideoQueueLabel, qosAttribute);
    
    _cameraSource = [[MPPCameraInputSource alloc] init];
    [_cameraSource setDelegate:self queue:_videoQueue];
    _cameraSource.sessionPreset = AVCaptureSessionPresetHigh;
    
    _cameraSource.cameraPosition = AVCaptureDevicePositionBack;
    // The frame's native format is rotated with respect to the portrait orientation.
    _cameraSource.orientation = AVCaptureVideoOrientationPortrait;
    
    self.mediapipeGraph = [[self class] loadGraphFromResource:kGraphName];
    self.mediapipeGraph.delegate = self;
    // Set maxFramesInFlight to a small value to avoid memory contention for real-time processing.
    self.mediapipeGraph.maxFramesInFlight = 2;
    
    
    // point value converter of mediapipe and SceneKit
    converter = [[MPP2SCN alloc] init];
    
    // captured data when recording
    recording = NO;
    scFrames = [NSMutableArray array];
    [self resetRecordedData];
}

// In this application, there is only one ViewController which has no navigation to other view
// controllers, and there is only one View with live display showing the result of running the
// MediaPipe graph on the live video feed. If more view controllers are needed later, the graph
// setup/teardown and camera start/stop logic should be updated appropriately in response to the
// appearance/disappearance of this ViewController, as viewWillAppear: can be invoked multiple times
// depending on the application navigation flow in that case.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_cameraSource requestCameraAccessWithCompletionHandler:^void(BOOL granted) {
        if (granted) {
            [self startGraphAndCamera];
            dispatch_async(dispatch_get_main_queue(), ^{
                _noCameraLabel.hidden = YES;
            });
        }
    }];
}

- (void)startGraphAndCamera {
    // Start running self.mediapipeGraph.
    NSError* error;
    if (![self.mediapipeGraph startWithError:&error]) {
        NSLog(@"Failed to start graph: %@", error);
    }
    
    // Start fetching frames from the camera.
    dispatch_async(_videoQueue, ^{
        [_cameraSource start];
    });
}

#pragma mark - MPPGraphDelegate methods

// Receives CVPixelBufferRef from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
            fromStream:(const std::string&)streamName {
    if (streamName == kOutputStream) {
        // Display the captured image on the screen.
        CVPixelBufferRetain(pixelBuffer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_renderer renderPixelBuffer:pixelBuffer];
            CVPixelBufferRelease(pixelBuffer);
        });
    }
}

// Receives a raw packet from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
       didOutputPacket:(const ::mediapipe::Packet&)packet
            fromStream:(const std::string&)streamName {
    if (recording) {
        if (streamName == kLandmarksOutputStream && !packet.IsEmpty()) {

            const auto& multi_hand_landmarks = packet.Get<std::vector<::mediapipe::NormalizedLandmarkList>>();
            
            if (multi_hand_landmarks.size()<=0 && scFrames.count<=0)
                return;
            
            // hand(s) are detected
            NSMutableDictionary *frameData = [NSMutableDictionary new];
            
            // loop hands
            NSMutableArray *hands = [NSMutableArray array];
            for (int hand_index = 0; hand_index < multi_hand_landmarks.size(); ++hand_index) {
                const auto& landmarks = multi_hand_landmarks[hand_index];
                
                // loop hands' node
                for (int i = 0; i < landmarks.landmark_size(); ++i) {
                    float mpp_x;
                    if (_renderer.mirrored) {
                        mpp_x = [converter convertXWhenMirroring:landmarks.landmark(i).x()];
                    } else {
                        mpp_x = [converter convertX:landmarks.landmark(i).x()];
                    }
                    float mpp_y = [converter convertY:landmarks.landmark(i).y()];
                    float mpp_z = [converter convertZ:landmarks.landmark(i).z()
                                               root_z:landmarks.landmark(0).z()];
                    NSString *pointName;
                    if([self isRightHand: landmarks.landmark(5).x() :landmarks.landmark(17).x()]) {
                        pointName = [NSString stringWithFormat:@"right_%d", i];
                    } else {
                        pointName = [NSString stringWithFormat:@"left_%d", i];
                    }
                    NSDictionary *pointLocation = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @(mpp_x), @"x",
                                                   @(mpp_y), @"y",
                                                   @(mpp_z), @"z",
                                                   pointName, @"pointName",
                                                   nil];
                    [hands addObject:pointLocation];
                    if(mpp_x < min_x) {
                        min_x = mpp_x;
                    }
                    if(mpp_x > max_x) {
                        max_x = mpp_x;
                    }
                    if(mpp_y < min_y) {
                        min_y = mpp_y;
                    }
                    if(mpp_y > max_y) {
                        max_y = mpp_y;
                    }
                    if(mpp_z > max_z) {
                        max_z = mpp_z;
                    }
                }
            }
            
            [frameData setObject:hands forKey:@"hands"];
            [scFrames addObject:frameData];
            
        }
    }
}

- (BOOL) isRightHand: (float) landMarks_5_x : (float) landMarks_17_x {
    return landMarks_5_x > landMarks_17_x;
}

#pragma mark - MPPInputSourceDelegate methods

// Must be invoked on _videoQueue.
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer
                timestamp:(CMTime)timestamp
               fromSource:(MPPInputSource*)source {
    if (source != _cameraSource) {
        NSLog(@"Unknown source: %@", source);
        return;
    }
    [self.mediapipeGraph sendPixelBuffer:imageBuffer
                              intoStream:kInputStream
                              packetType:MPPPacketTypePixelBuffer];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PreviewViewController *previewVC = [segue destinationViewController];
    previewVC.scFrames = scFrames;
    previewVC.min_x = min_x;
    previewVC.max_x = max_x;
    previewVC.min_y = min_y;
    previewVC.max_y = max_y;
    previewVC.max_z = max_z;
    previewVC.meaning = meaning;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL framesAreRecorded = scFrames.count > 0;
    return framesAreRecorded;
}


@end
