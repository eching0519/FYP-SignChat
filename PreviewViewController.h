//
//  PreviewViewController.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 18/1/2020.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : UIViewController<SCNSceneRendererDelegate>

@property (strong, nonatomic) IBOutlet SCNView *sceneView;

@property (strong, retain) NSMutableArray* scFrames;
@property float min_x;
@property float max_x;
@property float min_y;
@property float max_y;
@property float max_z;
@property NSString *meaning;

@end

NS_ASSUME_NONNULL_END
