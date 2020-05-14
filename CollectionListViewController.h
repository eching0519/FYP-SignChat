//
//  CollectionListViewController.h
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 3/2/2020.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UIViewController *cameraVC;

@property IBOutlet UITableView *tableView;
@property IBOutlet UISearchBar *searchBar;

- (void) resetTable: (NSArray*) newList;

@end

NS_ASSUME_NONNULL_END
