//
//  InfoUpdateViewController.m
//  _idx_ObjectDetectionGpuAppLibrary_EdgeDetectionGpuAppLibrary_FaceDetectionCpuAppLibrary_FaceDetectionGpuAppLibrary_HandDetectionGpuAppLibrary_HandTrackingGpuAppLibrary_MultiHandTrac_etc_01926E23_ios_min10.0
//
//  Created by Yee Ching Ng on 18/3/2020.
//

#import "InfoUpdateViewController.h"
#import "ServerConnector.h"
#import "MessageHelper.h"

@interface InfoUpdateViewController () {
    ServerConnector *connector;
    
    SignCollection *collection;
    Organisation *organisation;
    NSArray *subtitle;
    NSArray *labels;
    
    NSArray<UITextField*> *generalTextFields;
    NSArray<UITextField*> *organisationTextFields;
    NSArray<UITextField*> *contactPersonTextFields;
    NSArray *textFields;
    
    UITextField *activeField;
    CGPoint lastOffset;
    CGFloat keyboardHeight;
}

@end

@implementation InfoUpdateViewController

@synthesize collectionId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Information Update";
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0,15,0,15);
    
    connector = [[ServerConnector alloc] init];
    [connector setCollectionInformation:self];
    
    subtitle = @[@"Sign Collection", @"Organisation", @"Contact Person"];
    labels = @[
        @[@"ID",@"Name",@"Password",@"New Password",@"Re-type Password"],
        @[@"Name",@"Email",@"Telephone",@"Address", @""],
        @[@"Name",@"Title",@"Email",@"Telephone"]
    ];
    
    generalTextFields = @[
        [self makeCustomTextField:@"Required" enable:NO],
        [self makeCustomTextField:@"Required" enable:YES],
        [self makeCustomPasswordTextField:@"Required"],
        [self makeCustomPasswordTextField:@""],
        [self makeCustomPasswordTextField:@""]
    ];
    organisationTextFields = @[
        [self makeCustomTextField:@"Required" enable:YES],
        [self makeCustomTextField:@"Required" enable:YES],
        [self makeCustomTextField:@"Required" enable:YES],
        [self makeCustomTextField:@"Required" enable:YES]
    ];
    contactPersonTextFields = @[
        [self makeCustomTextField:@"Required" enable:YES],
        [self makeCustomTextField:@"" enable:YES],
        [self makeCustomTextField:@"" enable:YES],
        [self makeCustomTextField:@"" enable:YES]
    ];
    
    UITextField *textField = organisationTextFields[1];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    textField = contactPersonTextFields[2];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    textField = organisationTextFields[2];
    [textField setKeyboardType:UIKeyboardTypePhonePad];
    textField = contactPersonTextFields[3];
     [textField setKeyboardType:UIKeyboardTypePhonePad];
    textFields = @[generalTextFields, organisationTextFields, contactPersonTextFields];
    
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]]];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1 && indexPath.row==4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"readonly"];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"word"];
    
    // set label
    NSArray *myLabels = labels[indexPath.section];
    NSString *myLabel = myLabels[indexPath.row];
    [cell.textLabel setText:myLabel];
    
    // remove detail text label
    cell.detailTextLabel.hidden = YES;
    [[cell viewWithTag:3] removeFromSuperview];
    
    // set text field
    NSArray *myTextFields = textFields[indexPath.section];
    UITextField *textField = myTextFields[indexPath.row];
    
    [cell.contentView addSubview:textField];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.detailTextLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    textField.textAlignment = NSTextAlignmentRight;
    textField.delegate = self;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"header"];
    [header.textLabel setText:subtitle[section]];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewCell *footer = [self.tableView dequeueReusableCellWithIdentifier:@"footer"];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *myLabels = labels[section];
    return myLabels.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITextField *)makeCustomTextField: (NSString *) placeHolder enable: (BOOL) enable {
    UITextField *textField = [[UITextField alloc] init];
    textField.tag = 3;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [textField setPlaceholder:placeHolder];
    if(enable) {
        [textField setFont:[UIFont fontWithName:@"GillSans-Light" size:17.0]];
    }
    else {
        [textField setFont:[UIFont fontWithName:@"GillSans-SemiBold" size:17.0]];
    }
    [textField setTextColor:[UIColor colorWithRed:85/255 green:85/255 blue:85/255 alpha:1.0]];
    [textField setEnabled:enable];
    
    return textField;
}

- (UITextField *)makeCustomPasswordTextField: (NSString *) placeHolder {
    UITextField *textField = [[UITextField alloc] init];
    textField.tag = 3;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [textField setPlaceholder:placeHolder];
    [textField setFont:[UIFont fontWithName:@"GillSans-Light" size:17.0]];
    [textField setTextColor:[UIColor colorWithRed:85/255 green:85/255 blue:85/255 alpha:1.0]];
    [textField setSecureTextEntry:YES];
    [textField setAdjustsFontSizeToFitWidth:YES];
    textField.delegate = self;
    
    return textField;
}

- (IBAction)saveUpdate:(id)sender {
    [self updateInformation];
}

- (void) updateInformation {
    MessageHelper *helper = [[MessageHelper alloc] init];
    
    // Form validation
    if(generalTextFields[1].text.length==0 ||
       generalTextFields[2].text.length==0 ||
       organisationTextFields[0].text.length==0 ||
       organisationTextFields[1].text.length==0 ||
       organisationTextFields[2].text.length==0 ||
       organisationTextFields[3].text.length==0 ||
       contactPersonTextFields[0].text.length==0) {
        [helper alertMessage:@"Please complete all the required field" title:@"" sender:self];
        return;
    }
    if(![generalTextFields[3].text isEqualToString:generalTextFields[4].text]) {
        [helper alertMessage:@"Re-type password does not match with the new password." title:@"" sender:self];
        return;
    }
    if(contactPersonTextFields[2].text.length==0 &&
       contactPersonTextFields[3].text.length==0) {
        [helper alertMessage:@"Please enter at least one contact information of the contact person." title:@"" sender:self];
        return;
    }
    
    Organisation *myOrganisation = [[Organisation alloc] init];
    myOrganisation.organisationId = organisation.organisationId;
    myOrganisation.name = organisationTextFields[0].text;
    myOrganisation.email = organisationTextFields[1].text;
    myOrganisation.tel = organisationTextFields[2].text;
    myOrganisation.address = organisationTextFields[3].text;
    
    SignCollection *myCollection = [[SignCollection alloc] init];
    myCollection.organisationId = organisation.organisationId;
    myCollection.collectionId = collection.collectionId;
    myCollection.name = generalTextFields[1].text;
    myCollection.password = generalTextFields[3].text;
    myCollection.contactPerson = contactPersonTextFields[0].text;
    myCollection.contactPersonTitle = contactPersonTextFields[1].text;
    myCollection.contactPersonEmail = contactPersonTextFields[2].text;
    myCollection.contactPersonTel = contactPersonTextFields[3].text;
    
    NSString *currentPassword = generalTextFields[2].text;
    
    [connector updateCollectionInformation:myCollection
                              organisation:myOrganisation
                            verifyPassword:currentPassword
                                    sender:self];
}

- (void) setCollectionInformation: (SignCollection *) sc {
    collection = sc;
    
    [((UITextField *)generalTextFields[0]) setText:collectionId];
    [((UITextField *)generalTextFields[1]) setText:sc.name];
    [((UITextField *)contactPersonTextFields[0]) setText:sc.contactPerson];
    [((UITextField *)contactPersonTextFields[1]) setText:sc.contactPersonTitle];
    [((UITextField *)contactPersonTextFields[2]) setText:sc.contactPersonEmail];
    [((UITextField *)contactPersonTextFields[3]) setText:sc.contactPersonTel];
    
    [connector setOrganisationInformation:self organisationId: sc.organisationId];
}

- (void) setOrganisationInformation: (Organisation *) o {
    organisation = o;
    
    [((UITextField *)organisationTextFields[0]) setText:o.name];
    [((UITextField *)organisationTextFields[1]) setText:o.email];
    [((UITextField *)organisationTextFields[2]) setText:o.tel];
    [((UITextField *)organisationTextFields[3]) setText:o.address];
    
    if(o.collectionCount>1) {
        for(UITextField *textField in organisationTextFields) {
            //[textField setEnabled:NO];
            [textField setFont:[UIFont fontWithName:@"GillSans-SemiBold" size:17.0]];
        }
    } else {
        NSMutableArray *organisationLabels = [NSMutableArray arrayWithArray:labels[1]];
        [organisationLabels removeLastObject];
        
        labels = @[labels[0], [NSArray arrayWithArray:organisationLabels], labels[2]];
        [self.tableView reloadData];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(organisation.collectionCount<2)
        return YES;
    
    for(UITextField *field in organisationTextFields) {
        if(textField==field) {
            return NO;
        }
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

@end
