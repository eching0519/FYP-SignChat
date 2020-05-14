//
//  TranslateCameraViewController.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 23/1/2020.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface TranslateCameraViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingButton;

@property (strong, retain) NSString *selectedCollectionId;
@property (strong, retain) NSString *collectionName;

- (void) stopCamera;
- (void) startCamera;
- (void) showCollectionName;

@end
