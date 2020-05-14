//
//  TranslateCameraViewController.m
//  Mediapipe
//
//  Created by Yee Ching Ng on 23/1/2020.
//

#import "TranslateCameraViewController.h"

#import "mediapipe/objc/MPPGraph.h"
#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPLayerRenderer.h"

#include "mediapipe/framework/formats/landmark.pb.h"

#import "TableViewController.h"
#import "TranslateResultViewController.h"
#import "CollectionListViewController.h"
#import "MPP2SCN.h"
#import "ServerConnector.h"
#import "MessageHelper.h"

//static NSString* const kGraphName = @"multi_hand_tracking_mobile_gpu";
//
//static const char* kInputStream = "input_video";
//static const char* kOutputStream = "output_video";
//static const char* kLandmarksOutputStream = "multi_hand_landmarks";
//static const char* kVideoQueueLabel = "com.google.mediapipe.example.videoQueue";


@interface TranslateCameraViewController () <MPPGraphDelegate, MPPInputSourceDelegate> {
    MessageHelper* helper;
}

@property(nonatomic) MPPGraph* mediapipeGraph;

@end

@implementation TranslateCameraViewController {
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
    
    // captured data when recording
    BOOL recording;
    NSMutableArray *scFrames;
    float min_x;
    float max_x;
    float min_y;
    float max_y;
    float max_z;
    
    // point value converter of mediapipe and SceneKit
    MPP2SCN *converter;
}

@synthesize selectedCollectionId, collectionName;


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
    
    // set the default sign collection
    if([NSUserDefaults.standardUserDefaults objectForKey:@"SignChatTranslationCollectionID"]) {
        selectedCollectionId = [NSUserDefaults.standardUserDefaults objectForKey:@"SignChatTranslationCollectionID"];
    } else {
        selectedCollectionId = @"signchat";
    }
    
    if([NSUserDefaults.standardUserDefaults objectForKey:@"SignChatTranslationCollectionName"]) {
        collectionName = [NSUserDefaults.standardUserDefaults objectForKey:@"SignChatTranslationCollectionName"];
    } else {
        collectionName = @"Default Collection";
    }
    
    self.title = @"SignChat";
    
    self.navigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0,8,0,8);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"Copperplate" size:21]}];
    
    // set back button
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"Back"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"Back"];
    
    recording = NO;
    scFrames = [NSMutableArray array];
    converter = [[MPP2SCN alloc] init];
    
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
    [self startCamera];
    // Set maxFramesInFlight to a small value to avoid memory contention for real-time processing.
    self.mediapipeGraph.maxFramesInFlight = 2;
    
    [self showCollectionName];
    helper = [[MessageHelper alloc] init];
}

// In this application, there is only one ViewController which has no navigation to other view
// controllers, and there is only one View with live display showing the result of running the
// MediaPipe graph on the live video feed. If more view controllers are needed later, the graph
// setup/teardown and camera start/stop logic should be updated appropriately in response to the
// appearance/disappearance of this ViewController, as viewWillAppear: can be invoked multiple times
// depending on the application navigation flow in that case.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set the navigation bar color
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [_cameraSource requestCameraAccessWithCompletionHandler:^void(BOOL granted) {
        if (granted) {
            [self startGraphAndCamera];
            dispatch_async(dispatch_get_main_queue(), ^{
                _noCameraLabel.hidden = YES;
            });
        }
    }];
    
    [self startCamera];
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
            
            // hand(s) are detected
            NSMutableDictionary *frameData = [NSMutableDictionary new];
            
            const auto& multi_hand_landmarks = packet.Get<std::vector<::mediapipe::NormalizedLandmarkList>>();
            
            // loop hands
            NSMutableArray *hands = [NSMutableArray array];
            for (int hand_index = 0; hand_index < multi_hand_landmarks.size(); ++hand_index) {
                NSMutableArray *eachHand = [NSMutableArray array];
                const auto& landmarks = multi_hand_landmarks[hand_index];
                
                //NSLog(@"\tNumber of landmarks for hand[%d]: %d", hand_index, landmarks.landmark_size());
                
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
                    [eachHand addObject:pointLocation];
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
                if(eachHand.count==21) {
                    [hands addObject:eachHand];
                }
            }
            if(hands.count>0) {
                [frameData setObject:hands forKey:@"hands"];
                [scFrames addObject:frameData];
            }
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
    if([segue.identifier isEqualToString:@"translate"]) {
        TranslateResultViewController *translateResultVC = [segue destinationViewController];
        translateResultVC.scFrames = scFrames;
        translateResultVC.center_x = (min_x+max_x)/2;
        translateResultVC.center_y = (min_y+max_y)/2;
        translateResultVC.max_z = max_z;
        translateResultVC.cameraVC = self;
        translateResultVC.selectedCollectionId = selectedCollectionId;
    }
    [self stopCamera];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"translate"]) {
        return scFrames.count > 0;
    } else {
        return YES;
    }
}

- (IBAction)showMenu:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeCollectionBtn = [UIAlertAction actionWithTitle:@"Change Collection"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action) {
        // change collection
        CollectionListViewController *collectionList = [self.storyboard instantiateViewControllerWithIdentifier:@"collectionList"];
        collectionList.cameraVC = self;
        [self stopCamera];
        [self presentViewController:collectionList animated:YES completion:nil];
    }];
    
    UIAlertAction *manageCollectionBtn = [UIAlertAction actionWithTitle:@"Manage Collection"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action) {
        // manage collection
        [self loginCollection];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [menu addAction:changeCollectionBtn];
    [menu addAction:manageCollectionBtn];
    [menu addAction:cancelBtn];
    [self presentViewController:menu animated:YES completion:nil];
}

- (void) loginCollection {
    [self stopCamera];
    UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"Manage Collection" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Collection ID";
        NSString* loginId = [NSUserDefaults.standardUserDefaults objectForKey:@"SignChatLoginCollectionID"];
        textField.text = loginId;
    }];
    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction* loginAction = [UIAlertAction actionWithTitle:@"Login"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
        [self startCamera];
        NSArray<UITextField*> *textfieldArr = loginAlert.textFields;
        
        // login
        NSString *collectionId = loginAlert.textFields[0].text;
        NSString *password = loginAlert.textFields[1].text;
        
        ServerConnector *serverConnector = [[ServerConnector alloc] init];
        [serverConnector loginCollectionId:collectionId password:password sender:self];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [self startCamera];
    }];
    
    [loginAlert addAction:loginAction];
    [loginAlert addAction:cancelAction];
    [self presentViewController:loginAlert animated:YES completion:nil];
}

- (void) stopCamera {
    self.mediapipeGraph.delegate = nil;
}

- (void) startCamera {
    self.mediapipeGraph.delegate = self;
}

- (void) showCollectionName {
    NSString *message = [NSString stringWithFormat:@"Collection '%@' has been chosen.",collectionName];
    
    [helper showToastMessage:message duration:3 sender:self];
}


@end
