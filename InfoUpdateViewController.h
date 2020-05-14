//
//  InfoUpdateViewController.h
//  _idx_ObjectDetectionGpuAppLibrary_EdgeDetectionGpuAppLibrary_FaceDetectionCpuAppLibrary_FaceDetectionGpuAppLibrary_HandDetectionGpuAppLibrary_HandTrackingGpuAppLibrary_MultiHandTrac_etc_01926E23_ios_min10.0
//
//  Created by Yee Ching Ng on 18/3/2020.
//

#import <UIKit/UIKit.h>
#import "Organisation.h"
#import "SignCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface InfoUpdateViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, retain) NSString *collectionId;

- (IBAction)saveUpdate:(id)sender;

- (void) setCollectionInformation: (SignCollection *) collection;

- (void) setOrganisationInformation: (Organisation *) organisation;

@end

NS_ASSUME_NONNULL_END
