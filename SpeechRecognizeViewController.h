//
//  SpeechRecognizeViewController.h
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 22/3/2020.
//

#import <UIKit/UIKit.h>
#import <Speech/Speech.h>


@interface SpeechRecognizeViewController : UIViewController<SFSpeechRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

- (IBAction)recordModeChange:(id)sender;

- (IBAction)changeLangauge:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *button;

@property (strong, nonatomic) IBOutlet UIButton *languageButton;

@property (strong, nonatomic) IBOutlet UITextView *resultTextView;

@property (strong, nonatomic) IBOutlet UIView *languagePickerContainer;

@property (strong, nonatomic) IBOutlet UIPickerView *languagePicker;

@end

