//
//  SpeechRecognizeViewController.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 22/3/2020.
//

#import "SpeechRecognizeViewController.h"
#import "MessageHelper.h"

@interface SpeechRecognizeViewController () {
    BOOL isRecording;
    SFSpeechRecognizer *recognizer;
    SFSpeechAudioBufferRecognitionRequest *request;
    SFSpeechRecognitionTask *task;
    AVAudioEngine *audioEngine;
    AVAudioInputNode *inputNode;
    
    NSDictionary<NSString*, NSString*> *localeIdentifiers;
    NSArray<NSString*> *languageNames;
    NSString *userLang;
}

@end

@implementation SpeechRecognizeViewController

@synthesize button, resultTextView, languageButton, languagePicker, languagePickerContainer;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    userLang = [NSUserDefaults.standardUserDefaults objectForKey:@"SignChatSpeechLang"];
    if(userLang == nil) {
        userLang = @"en";
    }
    
    //dispatch_queue_t loadingQueue = dispatch_queue_create("LoadingQueue", nil);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isRecording = NO;
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:userLang];
        recognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
        recognizer.delegate = self;
        
        __block BOOL enableButton = NO;
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    enableButton = YES;
                    break;
                default:
                    break;
            }
        }];
        
        audioEngine = [[AVAudioEngine alloc] init];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [button setEnabled:enableButton];
            [button setImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
            [self setRecognizer:userLang];
        });
    });
    
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // set the navigation bar to transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.title = @"Lip-Reading Assistance";
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickerView)];
    [self.languagePickerContainer addGestureRecognizer:gestureRecognizer];
    
    // set locale identifier in order
    localeIdentifiers = @{
        @"Nederlands (Nederland)" : @"nl-NL",
        @"español (México)" : @"es-MX",
        @"français (France)" : @"fr-FR",
        @"中文（台灣）" : @"zh-TW",
        @"italiano (Italia)" : @"it-IT",
        @"Tiếng Việt (Việt Nam)" : @"vi-VN",
        @"français (Suisse)" : @"fr-CH",
        @"español (Chile)" : @"es-CL",
        @"English (South Africa)" : @"en-ZA",
        @"한국어(대한민국)" : @"ko-KR",
        @"català (Espanya)" : @"ca-ES",
        @"română (România)" : @"ro-RO",
        @"English (Philippines)" : @"en-PH",
        @"español (Latinoamérica)" : @"es-419",
        @"English (Canada)" : @"en-CA",
        @"English (Singapore)" : @"en-SG",
        @"English (India)" : @"en-IN",
        @"English (New Zealand)" : @"en-NZ",
        @"italiano (Svizzera)" : @"it-CH",
        @"français (Canada)" : @"fr-CA",
        @"हिन्दी (भारत)" : @"hi-IN",
        @"dansk (Danmark)" : @"da-DK",
        @"Deutsch (Österreich)" : @"de-AT",
        @"português (Brasil)" : @"pt-BR",
        @"粤语 (中国大陆)" : @"yue-CN",
        @"中文（中国大陆）" : @"zh-CN",
        @"svenska (Sverige)" : @"sv-SE",
        @"हिन्दी (भारत, TRANSLIT)" : @"hi-IN-translit",
        @"español (España)" : @"es-ES",
        @"العربية (المملكة العربية السعودية)" : @"ar-SA",
        @"magyar (Magyarország)" : @"hu-HU",
        @"français (Belgique)" : @"fr-BE",
        @"English (United Kingdom)" : @"en-GB",
        @"日本語（日本）" : @"ja-JP",
        @"中文（香港）" : @"zh-HK",
        @"suomi (Suomi)" : @"fi-FI",
        @"Türkçe (Türkiye)" : @"tr-TR",
        @"norsk bokmål (Norge)" : @"nb-NO",
        @"English (Indonesia)" : @"en-ID",
        @"English (Saudi Arabia)" : @"en-SA",
        @"polski (Polska)" : @"pl-PL",
        @"Bahasa Melayu (Malaysia)" : @"ms-MY",
        @"čeština (Česko)" : @"cs-CZ",
        @"Ελληνικά (Ελλάδα)" : @"el-GR",
        @"Indonesia (Indonesia)" : @"id-ID",
        @"hrvatski (Hrvatska)" : @"hr-HR",
        @"English (United Arab Emirates)" : @"en-AE",
        @"עברית (ישראל)" : @"he-IL",
        @"русский (Россия)" : @"ru-RU",
        @"上海话（中国大陆）" : @"wuu-CN",
        @"Deutsch (Deutschland)" : @"de-DE",
        @"Deutsch (Schweiz)" : @"de-CH",
        @"English (Australia)" : @"en-AU",
        @"Nederlands (België)" : @"nl-BE",
        @"ไทย (ไทย)" : @"th-TH",
        @"português (Portugal)" : @"pt-PT",
        @"slovenčina (Slovensko)" : @"sk-SK",
        @"English (United States)" : @"en-US",
        @"English (Ireland)" : @"en-IE",
        @"español (Colombia)" : @"es-CO",
        @"Hindi (Latin)" : @"hi-Latn",
        @"українська (Україна)" : @"uk-UA",
        @"español (Estados Unidos)" : @"es-US"
    };
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    languageNames = [[localeIdentifiers allKeys] sortedArrayUsingDescriptors:@[sort]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSUserDefaults.standardUserDefaults setObject:userLang forKey:@"SignChatSpeechLang"];
}

- (void) hidePickerView {
    if(languagePickerContainer.alpha>0)
        [UIView animateWithDuration:0.5 animations:^{
               [languagePickerContainer setAlpha:0];
        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)recordModeChange:(id)sender {
    if ([audioEngine isRunning]) {
        [self stopRecording];

    } else {
        [self startRecording];
    }
}

- (void) startRecording {
    self.resultTextView.text = @"";
    self.title = @"Recording...";
    [button setImage:[UIImage imageNamed:@"stopMicrophone"] forState:UIControlStateNormal];
    
    if (task != nil) {
        [task cancel];
        task = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryRecord
                         mode:AVAudioSessionModeMeasurement
                      options:AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
    
    if(error!=nil) {
        NSLog(@"%@",error);
        return;
    }
    
    [audioSession setActive:YES
                withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                      error:&error];
    
    if(error!=nil) {
        NSLog(@"%@",error);
        return;
    }
    
    inputNode = audioEngine.inputNode;
    
    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    [request setShouldReportPartialResults:YES];
    
    if (@available(iOS 13, *)) {
        [request setRequiresOnDeviceRecognition:YES];
    }
    
    task = [recognizer recognitionTaskWithRequest:request
                                    resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        if(error != nil) {
            if (error.code == 1101) {
                return;
            }
            
            MessageHelper *helper = [[MessageHelper alloc] init];
            NSString *langName = [[[NSLocale alloc] initWithLocaleIdentifier:userLang] displayNameForKey:NSLocaleIdentifier value:userLang];
            NSString *msg;
            
            if (error.code == 1103) {
                msg = [NSString stringWithFormat:@"Your device have no ML model for %@",langName];
            } else {
                msg = [error localizedDescription];
            }
            [helper alertMessage:msg title:@"Error" sender:self];
            [self stopRecording];
            
            NSLog(@"%@",error);
            return;
        }
        
        BOOL isFinal = NO;
        
        if (result != nil) {
            self.resultTextView.text = [result.bestTranscription formattedString];
            isFinal = [result isFinal];
        }
        
        if(error != nil || isFinal) {
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            
            request = nil;
            task = nil;
            
            [button setEnabled:YES];
        }
    }];
    
    AVAudioFormat *format = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [request appendAudioPCMBuffer:buffer];
    }];
    
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    if(error!=nil) {
        NSLog(@"%@",error);
    }
    
}

- (IBAction)changeLangauge:(id)sender {
    if(languagePickerContainer.alpha>0)
        [UIView animateWithDuration:0.5 animations:^{
            [languagePickerContainer setAlpha:0];
        }];
    else
        [UIView animateWithDuration:0.5 animations:^{
            [languagePickerContainer setAlpha:1];
        }];
}

- (void)stopRecording {
    dispatch_async(dispatch_get_main_queue(), ^{
        [inputNode removeTapOnBus:0];
        [inputNode reset];
        [audioEngine stop];
        [request endAudio];
        [task cancel];
        task = nil;
        request = nil;
    });
    self.title = @"Lip-Reading Assistance";
    [button setImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    if (available) {
        [button setEnabled:YES];
    } else {
        [button setEnabled:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return languageNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return languageNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *langName = languageNames[row];
    NSString *identifier = [localeIdentifiers objectForKey:langName];
    [self setRecognizer:identifier];
}

- (void) setRecognizer: (NSString*) localeIdentifier {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    recognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    recognizer.delegate = self;
    
    NSString *langName = [locale displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
    [languageButton setTitle:[NSString stringWithFormat:@"Language: %@",langName] forState:UIControlStateNormal];
    userLang = localeIdentifier;
    
    NSInteger languagePickerIndex = [languageNames indexOfObject:langName];
    [languagePicker selectRow:languagePickerIndex inComponent:0 animated:NO];
    [self stopRecording];
}

@end
