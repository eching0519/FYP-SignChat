//
//  TableViewController.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 24/1/2020.
//

#import "TableViewController.h"
#import "SignMotionViewController.h"
#import "ServerConnector.h"
#import "InfoUpdateViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController {
    NSArray *signData;
    NSArray *filteredData;
    NSString *collectionName;
    
    ServerConnector *serverConnector;
    
    UITapGestureRecognizer *tapGestureRecognizer;
}

@synthesize collectionId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the navigation bar to transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    signData = [NSArray array];
    filteredData = [NSArray array];
    
    // get data from server
    serverConnector = [[ServerConnector alloc] init];
    [serverConnector getCollectionSignWithSender:self];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0,15,0,15);
    
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]]];
}

- (void) reloadData {
    [serverConnector getCollectionSignWithSender:self];
}

- (void) resetTable: (NSArray*) newSignList {
    signData = newSignList;
    filteredData = signData;
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchBar.searchTextField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    NSDictionary* sign_dic = filteredData[indexPath.row];
    cell.textLabel.text = [sign_dic objectForKey:@"meaning"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"No. of datasets: %@",[sign_dic objectForKey:@"count"]];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filteredData.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length>0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"meaning contains[cd] %@",searchText];
        filteredData = [signData filteredArrayUsingPredicate:predicate];
    } else {
        filteredData = signData;
    }
    
    NSLog(@"%@",filteredData);
    
    [self.tableView reloadData];
}

- (IBAction) showMenu:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *addSignBtn = [UIAlertAction actionWithTitle:@"Add Sign"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action) {
        // add sign
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* addSignCameraView = [storyboard instantiateViewControllerWithIdentifier:@"addSignCameraView"];
        [self.navigationController pushViewController:addSignCameraView animated:YES];
    }];
    
    UIAlertAction *settingBtn = [UIAlertAction actionWithTitle:@"Update Info"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action) {
        // setting
        [self updateInfo];
    }];
    
    UIAlertAction *aiModelBtn = [UIAlertAction actionWithTitle:@"AI Model"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action) {
        // check ai model
        [serverConnector showModelInformationOf:collectionId sender:self];
    }];
    
    UIAlertAction *logoutBtn = [UIAlertAction actionWithTitle:@"Logout"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action) {
        // logout
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* translateCameraView = [storyboard instantiateViewControllerWithIdentifier:@"translateCameraView"];
        [self.navigationController setViewControllers:@[translateCameraView] animated:YES];
        
        // update model
        [serverConnector updateAIModelOfCollection:collectionId sender:self showMessage:NO];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [menu addAction:addSignBtn];
    [menu addAction:settingBtn];
    [menu addAction:aiModelBtn];
    [menu addAction:logoutBtn];
    [menu addAction:cancelBtn];
    [self presentViewController:menu animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* sign_dic = filteredData[indexPath.row];
    NSString *meaning = [sign_dic objectForKey:@"meaning"];
    
    [serverConnector displaySignMotionPageByMeaning:meaning sender:self];
}

- (void) updateInfo {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController* settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"updateInfoViewController"];
    
    InfoUpdateViewController* infoUpdateViewController = [storyboard instantiateViewControllerWithIdentifier:@"infoUpdate"];
    infoUpdateViewController.collectionId = collectionId;
    
    [self.navigationController pushViewController:infoUpdateViewController animated:YES];
    
}


@end
