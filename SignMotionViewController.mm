//
//  SignMotionViewController.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 28/1/2020.
//

#import "SignMotionViewController.h"
#import "SceneViewCell.h"
#import "ServerConnector.h"
#import "TableViewController.h"
#import "ViewController.h"

@interface SignMotionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@end

@implementation SignMotionViewController {
    int currentSignId;
    CGFloat xOffset;
}

@synthesize collectionView, meaningLabel, pageNo, totalPageNo, motions, meaning;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    totalPageNo.text = [NSString stringWithFormat: @"/ %d",motions.count];
    pageNo.delegate = self;
    
    self.title = @"Datasets";
    self.meaningLabel.text = [NSString stringWithFormat:@"- %@ -",meaning];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissingKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    currentSignId = [self getSignIdFromIndex:0];
    
    xOffset = self.collectionView.bounds.size.width;
}

- (void) resetCollectionView: (NSArray*) newMotions {
    motions = [NSMutableArray arrayWithArray:newMotions];
    totalPageNo.text = [NSString stringWithFormat: @"/ %d",motions.count];
    pageNo.text = @"1";
    currentSignId = [self getSignIdFromIndex:0];
    [collectionView reloadData];
    [collectionView setScrollsToTop:YES];
}

- (NSInteger) getSignIdFromIndex: (int) index {
    NSDictionary *data_dic = [motions objectAtIndex:index];
    NSNumber *id_num = [data_dic objectForKey:@"signId"];
    return id_num.intValue;
}

- (void) dismissingKeyboard {
    [self.view endEditing:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return motions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SceneViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    cell.scFrames = [motions objectAtIndex:indexPath.row];
    [cell configSceneView];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = collectionView.frame.size.height;
    CGFloat width  = collectionView.frame.size.width;
    return CGSizeMake(width, height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    CGFloat w = scrollView.bounds.size.width;
    int page = ((int)ceil(x/w))+1;
    if(page > motions.count) {
        page = motions.count;
    }
    pageNo.text = @(page).stringValue;
    
    currentSignId = [self getSignIdFromIndex:page-1];

}

- (IBAction)scrollByPageNo:(id)sender {
    int pageNumber = pageNo.text.intValue;
    if(pageNumber<=0) {
        pageNumber = 1;
        pageNo.text = @(1).stringValue;
    }
    if(pageNumber>motions.count){
        pageNumber = motions.count;
        pageNo.text = @(motions.count).stringValue;
    }
    
    BOOL animateScoll = YES;
    CGFloat destinationX = xOffset*(pageNumber-1);
    if(fabs(self.collectionView.contentOffset.x-destinationX)>xOffset*5) {
        animateScoll = NO;
    }
    [self.collectionView setContentOffset:CGPointMake(xOffset*(pageNumber-1), self.collectionView.contentOffset.y)
                                 animated:animateScoll];
}

# pragma remove function

- (IBAction)removeData:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Do you want to remove the sign on page %@? (ID: %d)",pageNo.text, currentSignId] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // confirm remove the data
        ServerConnector *serverConnector = [[ServerConnector alloc] init];
        [serverConnector removeSignBySignId:currentSignId sender:self];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSArray *viewControllers = [self.navigationController viewControllers];
    TableViewController *tableViewController = viewControllers[0];
    [tableViewController reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    ViewController *vc = [segue destinationViewController];
    vc.meaning = meaning;
}


@end
