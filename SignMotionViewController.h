//
//  SignMotionViewController.h
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 28/1/2020.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignMotionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *meaningLabel;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UITextField *pageNo;

@property (strong, nonatomic) IBOutlet UILabel *totalPageNo;

@property (strong, retain) NSMutableArray* motions;

@property (strong, retain) NSString *meaning;

- (void) resetCollectionView: (NSArray*) newMotions;

@end

NS_ASSUME_NONNULL_END
