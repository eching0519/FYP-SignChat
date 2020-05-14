//
//  SceneViewCell.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 28/1/2020.
//

#import "SceneViewCell.h"

@implementation SceneViewCell {
    SCNScene *scene;
    NSArray *frames_arr;
    
    // play animation
    int count;
    NSTimeInterval frameTime;
}
@synthesize sceneView, startBtn, scFrames, signId;

- (void) configSceneView {
    NSNumber *number = [scFrames objectForKey:@"signId"];
    signId = [number intValue];
    scene = [SCNScene scene];
    
    sceneView.scene = scene;
    sceneView.delegate = self;
    
    sceneView.autoenablesDefaultLighting = YES;
    [sceneView stop:self];
    
    count = 0;
    frameTime = 0;
    
    [self resetScene];
    
    frames_arr = [scFrames objectForKey:@"frames"];
    [sceneView stop:self];
}

- (void) resetScene {
    for (SCNNode *node in [scene.rootNode childNodes]) {
        [node removeFromParentNode];
    }
    
    // light
    SCNLight *light = [SCNLight light];
    light.color = [UIColor whiteColor];
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    lightNode.position = SCNVector3Make(0,100,-100);
    [scene.rootNode addChildNode:lightNode];
    SCNNode *light2Node = [SCNNode node];
    light2Node.light = light;
    light2Node.position = SCNVector3Make(0,100,100);
    [scene.rootNode addChildNode:light2Node];
    
    // camera
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 20);
    [scene.rootNode addChildNode: cameraNode];
}

- (void) addHandNode:(NSArray*) nodePositionArray {
    SCNVector3 positions[21];
    int index = 0;
    for (int i = 0 ; i < nodePositionArray.count ; i+=3) {
        NSNumber *temp_num = nodePositionArray[i];
        float x = temp_num.floatValue;
        temp_num = nodePositionArray[i+1];
        float y = temp_num.floatValue;
        temp_num = nodePositionArray[i+2];
        float z = temp_num.floatValue;
        positions[index] = SCNVector3Make(x,y,z);

        SCNSphere *pointNode = [SCNSphere sphereWithRadius: 0.2];
        pointNode.firstMaterial.diffuse.contents = [UIColor colorWithWhite:0.9 alpha:1];
        SCNNode *node = [SCNNode nodeWithGeometry: pointNode];
        [scene.rootNode addChildNode: node];
        node.position = positions[index];
        
        index++;
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

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    if(count >= frames_arr.count) {
        [sceneView pause:self];
        count = 0;
        return;
    }
    
    if (time > frameTime) {
        frameTime = time + 0.075;
        
        [self resetScene];
        
        NSMutableDictionary *hand_dic = frames_arr[count];
        
        NSMutableArray *leftHand_arr = [NSMutableArray array];
        NSMutableArray *rightHand_arr = [NSMutableArray array];
        for(int i = 0 ; i<21 ; i++) {
            NSString* leftKey = [NSString stringWithFormat:@"left_%d_x",i];
            NSNumber *temp = [hand_dic objectForKey:leftKey];
            if(![temp isEqual:[NSNull new]]) {
                [leftHand_arr addObject:temp];
            }
            leftKey = [NSString stringWithFormat:@"left_%d_y",i];
            temp = [hand_dic objectForKey:leftKey];
            if(![temp isEqual:[NSNull new]]) {
                [leftHand_arr addObject:temp];
            }
            leftKey = [NSString stringWithFormat:@"left_%d_z",i];
            temp = [hand_dic objectForKey:leftKey];
            if(![temp isEqual:[NSNull new]]) {
                [leftHand_arr addObject:temp];
            }
            
            NSString* rightKey = [NSString stringWithFormat:@"right_%d_x",i];
            temp = [hand_dic objectForKey:rightKey];
            if(![temp isEqual:[NSNull new]]) {
                [rightHand_arr addObject:temp];
            }
            rightKey = [NSString stringWithFormat:@"right_%d_y",i];
            temp = [hand_dic objectForKey:rightKey];
            if(![temp isEqual:[NSNull new]]) {
                [rightHand_arr addObject:temp];
            }
            rightKey = [NSString stringWithFormat:@"right_%d_z",i];
            temp = [hand_dic objectForKey:rightKey];
            if(![temp isEqual:[NSNull new]]) {
                [rightHand_arr addObject:temp];
            }
        }
        
        if(leftHand_arr.count>0) {
            [self addHandNode:leftHand_arr];
        }
        if(rightHand_arr.count>0) {
            [self addHandNode:rightHand_arr];
        }
        
        count++;
    }
}


- (IBAction)playAnimation:(id)sender {
    [startBtn setHidden:YES];
    [sceneView stop:self];
    [sceneView play:self];
    [self performSelector:@selector(showStartButton) withObject:self afterDelay:(0.075*frames_arr.count+0.5) ];
}

- (void) showStartButton {
    [startBtn setHidden:NO];
}

@end
