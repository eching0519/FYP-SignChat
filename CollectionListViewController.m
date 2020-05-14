//
//  CollectionListViewController.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 3/2/2020.
//

#import "CollectionListViewController.h"
#import "TranslateCameraViewController.h"
#import "ServerConnector.h"

@interface CollectionListViewController ()

@end

@implementation CollectionListViewController {
    NSMutableArray *collectionList;
    NSArray *filteredList;
}

@synthesize cameraVC, tableView, searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getCollectionList];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0,15,0,15);
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchBar.searchTextField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) getCollectionList {
    collectionList = [NSMutableArray array];
    filteredList = [NSArray array];
    
    ServerConnector *serverConnector = [[ServerConnector alloc] init];
    [serverConnector getCollectionListWithSender:self];
}

- (void) resetTable: (NSArray*) newList {
    collectionList = [NSMutableArray arrayWithArray:newList];
    filteredList = collectionList;
    [tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    TranslateCameraViewController *cameraViewController = cameraVC;
    [cameraViewController startCamera];
}

- (IBAction)closeViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    NSDictionary *data = [filteredList objectAtIndex:indexPath.row];
    cell.textLabel.text = [data objectForKey:@"collectionName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Total no. of datasets: %@",[data objectForKey:@"total"]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filteredList.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [filteredList objectAtIndex:indexPath.row];
    
    TranslateCameraViewController *cameraViewController = cameraVC;
    cameraViewController.collectionName = [data objectForKey:@"collectionName"];
    cameraViewController.selectedCollectionId = [data objectForKey:@"collectionId"];
    [self dismissViewControllerAnimated:YES completion:^{
        [cameraViewController showCollectionName];
    }];
    
    [NSUserDefaults.standardUserDefaults setObject:[data objectForKey:@"collectionId"] forKey:@"SignChatTranslationCollectionID"];
    [NSUserDefaults.standardUserDefaults setObject:[data objectForKey:@"collectionName"] forKey:@"SignChatTranslationCollectionName"];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length>0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"collectionName contains[cd] %@",searchText];
        filteredList = [collectionList filteredArrayUsingPredicate:predicate];
    } else {
        filteredList = collectionList;
    }
    
    [self.tableView reloadData];
}

@end
