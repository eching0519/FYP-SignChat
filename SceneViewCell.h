//
//  SceneViewCell.h
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 28/1/2020.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SceneViewCell : UICollectionViewCell <SCNSceneRendererDelegate>

@property (strong, nonatomic) IBOutlet SCNView *sceneView;

@property (strong, nonatomic) IBOutlet UIButton *startBtn;

@property (strong, retain) NSMutableDictionary* scFrames;

@property int signId;

- (void) configSceneView;

@end

NS_ASSUME_NONNULL_END
