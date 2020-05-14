//
//  PreviewViewController.m
//  Mediapipe
//
//  Created by Yee Ching Ng on 18/1/2020.
//

#import "PreviewViewController.h"
#import "TableViewController.h"
#import "ServerConnector.h"
#import "MessageHelper.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController {
    SCNScene *scene;
    NSArray<SCNNode*> *handNode_arr;
    
    // play animation
    int count;
    NSTimeInterval frameTime;
}

@synthesize sceneView, scFrames;
@synthesize min_x, max_x, min_y, max_y, max_z, meaning;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    self.title = @"Preview";
    scene = [SCNScene scene];
    sceneView.scene = scene;
    sceneView.delegate = self;
    
    sceneView.autoenablesDefaultLighting = YES;
    [sceneView play:self];
    
    [self resetScene];
    
    NSMutableDictionary *hand_dic = (NSDictionary*) [scFrames objectAtIndex:count];
    NSMutableArray *hands_arr = (NSMutableArray*) [hand_dic objectForKey:@"hands"];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAgain)];
    count = 0;
    frameTime = 0;
    [sceneView addGestureRecognizer:gestureRecognizer];
}

- (void) playAgain {
    [sceneView stop:self];
    count = 0;
    [sceneView play:self];
}

- (void) addHandNode:(NSArray*) nodePositionArray {
    for (int i = 0 ; i < nodePositionArray.count ; i++) {
        NSDictionary *nodePosition = nodePositionArray[i];
        NSNumber *temp_num = (NSNumber*)[nodePosition objectForKey:@"x"];
        float x = [temp_num floatValue];
        temp_num = (NSNumber*)[nodePosition objectForKey:@"y"];
        float y = [temp_num floatValue];
        temp_num = (NSNumber*)[nodePosition objectForKey:@"z"];
        float z = [temp_num floatValue];
        
        SCNSphere *pointNode = [SCNSphere sphereWithRadius: 0.2];
        pointNode.firstMaterial.diffuse.contents = [UIColor colorWithWhite:0.9 alpha:1];
        SCNNode *node = [SCNNode nodeWithGeometry: pointNode];
        
        [scene.rootNode addChildNode: node];
        node.position = SCNVector3Make(x,y,z);
    }
    
    SCNVector3 positions[21];
    for(int i = 0 ; i < nodePositionArray.count ; i++) {
        positions[i] = [self getPositionFromNodeDictionary: nodePositionArray[i]];
    }
    
    [self drawLinePositionA: positions[0] positionB: positions[1]];
    [self drawLinePositionA: positions[1] positionB: positions[2]];
    [self drawLinePositionA: positions[2] positionB: positions[3]];
    [self drawLinePositionA: positions[3] positionB: positions[4]];
    [self drawLinePositionA: positions[2] positionB: positions[5]];
    [self drawLinePositionA: positions[5] positionB: positions[6]];
    [self drawLinePositionA: positions[6] positionB: positions[7]];
    [self drawLinePositionA: positions[7] positionB: positions[8]];
    [self drawLinePositionA: positions[5] positionB: positions[9]];
    [self drawLinePositionA: positions[9] positionB: positions[10]];
    [self drawLinePositionA: positions[10] positionB: positions[11]];
    [self drawLinePositionA: positions[11] positionB: positions[12]];
    [self drawLinePositionA: positions[9] positionB: positions[13]];
    [self drawLinePositionA: positions[13] positionB: positions[14]];
    [self drawLinePositionA: positions[14] positionB: positions[15]];
    [self drawLinePositionA: positions[15] positionB: positions[16]];
    [self drawLinePositionA: positions[13] positionB: positions[17]];
    [self drawLinePositionA: positions[17] positionB: positions[18]];
    [self drawLinePositionA: positions[18] positionB: positions[19]];
    [self drawLinePositionA: positions[19] positionB: positions[20]];
    [self drawLinePositionA: positions[0] positionB: positions[5]];
    [self drawLinePositionA: positions[0] positionB: positions[9]];
    [self drawLinePositionA: positions[0] positionB: positions[13]];
    [self drawLinePositionA: positions[0] positionB: positions[17]];
}

- (SCNVector3) getPositionFromNodeDictionary: (NSDictionary*) nodePosition {
    NSNumber *temp_num = (NSNumber*)[nodePosition objectForKey:@"x"];
    float x = [temp_num floatValue];
    temp_num = (NSNumber*)[nodePosition objectForKey:@"y"];
    float y = [temp_num floatValue];
    temp_num = (NSNumber*)[nodePosition objectForKey:@"z"];
    float z = [temp_num floatValue];
    return SCNVector3Make(x,y,z);
}

- (void) drawLinePositionA: (SCNVector3) positionA positionB: (SCNVector3) positionB {
    SCNVector3 vector = SCNVector3Make(positionA.x-positionB.x, positionA.y-positionB.y, positionA.z-positionB.z);
    double distance = sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z);
    SCNVector3 midPosition = SCNVector3Make((positionA.x+positionB.x)/2, (positionA.y+positionB.y)/2, (positionA.z+positionB.z)/2);
    
    SCNCapsule* lineGeometry = [SCNCapsule capsuleWithCapRadius:0.15 height:distance];
    lineGeometry.firstMaterial.diffuse.contents = [UIColor colorWithWhite:0.9 alpha:0.9];
    
    SCNNode* node = [SCNNode nodeWithGeometry:lineGeometry];
    node.position = midPosition;
    [node lookAt:positionB up:scene.rootNode.worldUp localFront:node.worldUp];
    [scene.rootNode addChildNode:node];
}


- (void) resetScene {
    for (SCNNode *node in [scene.rootNode childNodes]) {
        [node removeFromParentNode];
    }
    
    float center_x = (min_x + max_x) / 2;
    float center_y = (min_y + max_y) / 2;
    
    // light
    SCNLight *light = [SCNLight light];
    light.color = [UIColor whiteColor];
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    lightNode.position = SCNVector3Make(center_x,center_y+50,-max_z-100);
    [scene.rootNode addChildNode:lightNode];
    SCNNode *light2Node = [SCNNode node];
    light2Node.light = light;
    light2Node.position = SCNVector3Make(center_x,center_y+50,max_z+100);
    [scene.rootNode addChildNode:light2Node];
    
    // camera
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(center_x, center_y, max_z+20);
    [scene.rootNode addChildNode: cameraNode];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    if(count >= scFrames.count) {
        [sceneView pause:self];
        count = 0;
        return;
    }
    
    if (time > frameTime) {
        frameTime = time + 0.075;
        
        [self resetScene];
        
        NSMutableDictionary *hand_dic = (NSDictionary*) [scFrames objectAtIndex:count];
        NSMutableArray *hands_arr = (NSMutableArray*) [hand_dic objectForKey:@"hands"];
        
        for(int i = 0 ; i<hands_arr.count/21 ; i++) {
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(i*21, 21)];
            [self addHandNode:[hands_arr objectsAtIndexes:indexSet]];
        }

        NSLog(@"count: %d/%d",count,scFrames.count-1);
        count++;
    }
}

- (IBAction) saveSign {
    if (meaning != nil) {
        TableViewController *tableViewController = self.navigationController.viewControllers[0];
        NSDictionary* sign = @{
            @"collectionId" : tableViewController.collectionId,
            @"meaning" : meaning,
            @"camera_x" : @((min_x + max_x) / 2),
            @"camera_y" : @((min_y + max_y) / 2),
            @"camera_z" : @(max_z+20),
            @"frames" : scFrames
        };
        ServerConnector *serverConnector = [[ServerConnector alloc] init];
        [serverConnector addSign:sign sender:self];
    
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Last Step!" message:@"Please enter the meaning of your sign." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        NSString *inputText = alert.textFields[0].text;
        if (inputText.length <= 0 ) {
            MessageHelper *helper = [[MessageHelper alloc] init];
            [helper showToastMessage: @"Your sign has not been saved as no message is entered."
                         duration: 1.5
             sender: self];
            
        } else {
            TableViewController *tableViewController = self.navigationController.viewControllers[0];
            NSDictionary* sign = @{
                @"collectionId" : tableViewController.collectionId,
                @"meaning" : inputText,
                @"camera_x" : @((min_x + max_x) / 2),
                @"camera_y" : @((min_y + max_y) / 2),
                @"camera_z" : @(max_z+20),
                @"frames" : scFrames
            };
            
            ServerConnector *serverConnector = [[ServerConnector alloc] init];
            [serverConnector addSign:sign sender:self];
        }
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    [alert addAction:saveAction];
    [alert addAction:cancelAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Meaning";
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBg"] forBarMetrics:UIBarMetricsDefault];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
