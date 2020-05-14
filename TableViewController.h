//
//  TableViewController.h
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 24/1/2020.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate>

@property IBOutlet UITableView *tableView;
@property IBOutlet UISearchBar *searchBar;
@property NSString *collectionId;

- (void) reloadData;
- (void) resetTable: (NSArray*) newSignList;    // call by server api

@end

NS_ASSUME_NONNULL_END
