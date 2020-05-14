//
//  TranslateViewController.h
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 1/2/2020.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <NaturalLanguage/NaturalLanguage.h>

NS_ASSUME_NONNULL_BEGIN

@interface TranslateResultViewController : UIViewController

@property (strong, nonatomic) UIViewController *cameraVC;

@property (strong, nonatomic) IBOutlet UITextView *resultTextView;

- (IBAction)speak:(id)sender;

@property (strong, retain) NSArray* scFrames;
@property float center_x;
@property float center_y;
@property float max_z;

@property NSString *selectedCollectionId;

@end

NS_ASSUME_NONNULL_END

