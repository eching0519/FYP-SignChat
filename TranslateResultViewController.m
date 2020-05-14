//
//  TranslateViewController.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 1/2/2020.
//

#import "TranslateResultViewController.h"
#import "TranslateCameraViewController.h"
#import "ServerConnector.h"

@interface TranslateResultViewController ()

@end

@implementation TranslateResultViewController {
    NSMutableArray *frames;
}

@synthesize cameraVC, resultTextView, scFrames;
@synthesize center_x ,center_y, max_z, selectedCollectionId;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0,15,0,15);
    
    frames = [NSMutableArray array];
    for(int i = 0 ; i<scFrames.count ; i++) {
        
        NSDictionary *dic = scFrames[i];
        NSArray *arr = [dic objectForKey:@"hands"];
        
        NSMutableArray *temp_arr = [NSMutableArray array];
        for(int j = 0 ; j<arr.count ; j++) {
            [temp_arr addObjectsFromArray:arr[j]];
        }
        arr = temp_arr;
        
        NSMutableDictionary *node = [NSMutableDictionary dictionary];
        for(int j = 0 ; j<arr.count ; j++) {
            
            NSDictionary *node_dic = arr[j];
            
            NSString *pointName = [node_dic objectForKey:@"pointName"];
            NSNumber *num = [node_dic objectForKey:@"x"];
            float x = num.floatValue;
            num = [node_dic objectForKey:@"y"];
            float y = num.floatValue;
            num = [node_dic objectForKey:@"z"];
            float z = num.floatValue;
            
            [node setValue:@(x-center_x) forKey:[NSString stringWithFormat:@"%@_x",pointName]];
            [node setValue:@(y-center_y) forKey:[NSString stringWithFormat:@"%@_y",pointName]];
            [node setValue:@(z-max_z) forKey:[NSString stringWithFormat:@"%@_z",pointName]];
        }
        
        if([node objectForKey:@"left_0_x"] == nil) {
            for(int j = 0 ; j<21 ; j++) {
                [node setValue:@(-99.99) forKey:[NSString stringWithFormat:@"left_%d_x",j]];
                [node setValue:@(-99.99) forKey:[NSString stringWithFormat:@"left_%d_y",j]];
                [node setValue:@(-99.99) forKey:[NSString stringWithFormat:@"left_%d_z",j]];
            }
        }
        if([node objectForKey:@"right_0_x"] == nil) {
            for(int j = 0 ; j<21 ; j++) {
                [node setValue:@(-99.99) forKey:[NSString stringWithFormat:@"right_%d_x",j]];
                [node setValue:@(-99.99) forKey:[NSString stringWithFormat:@"right_%d_y",j]];
                [node setValue:@(-99.99) forKey:[NSString stringWithFormat:@"right_%d_z",j]];
            }
        }
        [frames addObject:node];
    }
    
    [self translateByAI];
}

- (void) translateByAI {
    ServerConnector *serverConnector = [[ServerConnector alloc] init];
    [serverConnector translate:frames ofCollectionId:selectedCollectionId sender:self];
}

- (IBAction)closeViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    TranslateCameraViewController *previousView = cameraVC;
    previousView.startCamera;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)speak:(id)sender {
    NSString *myText = resultTextView.text;
    
    NLLanguageRecognizer *recognizer = [[NLLanguageRecognizer alloc] init];
    [recognizer processString:myText];
    NLLanguage language = recognizer.dominantLanguage;
    NSLog(@"%@", language);
    
    AVSpeechUtterance *speechUtterance = [AVSpeechUtterance speechUtteranceWithString:myText];
    [speechUtterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:language]];
    AVSpeechSynthesizer *speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    [speechSynthesizer speakUtterance:speechUtterance];
    
}
@end
