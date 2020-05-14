//
//  ServerConnector.m
//  Mediapipe
//
//  Created by Yee Ching Ng on 4/2/2020.
//

#import "ServerConnector.h"
#import "MessageHelper.h"
#import "TableViewController.h"
#import "TranslateResultViewController.h"
#import "CollectionListViewController.h"
#import "TableViewController.h"
#import "SignMotionViewController.h"
#import "InfoUpdateViewController.h"


@implementation ServerConnector {
    NSURLSessionConfiguration* defaultConfigObj;
    NSURLSession *defaultSession;
    
    NSString* serverURL_str;
    NSString* aiServiceURL_str;
}

- (instancetype)init {
    if (self = [super init]) {
        // Initialize self
        defaultConfigObj = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfigObj.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObj
                                                       delegate:self
                                                  delegateQueue: [NSOperationQueue mainQueue]];
        
        NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"Info" ofType:@"plist"];
        NSDictionary* urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        serverURL_str = [[urlDictionary objectForKey:@"ServerConnection"] objectForKey:@"serverURL"];
        aiServiceURL_str = [[urlDictionary objectForKey:@"ServerConnection"] objectForKey:@"aiServiceURL"];
    }
    return self;
}

- (void) loginCollectionId: (NSString*) collectionId password: (NSString*) password sender: (UIViewController*) viewController {
    MessageHelper *helper = [[MessageHelper alloc] init];
    UIAlertController* toastMessage = [helper showToastMessage: @"loading..." sender: viewController];
    
    NSString *url_str = [serverURL_str stringByAppendingString:@"login.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSString* dataString = [NSString stringWithFormat:@"collectionId=%@&password=%@",collectionId, password];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [helper alertMessage:[NSString stringWithFormat:@"%@",error] title:@"Error" sender:viewController];
            return;
        }
        
        if(httpResponse.statusCode == 200)
        {
            NSError *error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSString* message = [response_dic objectForKey:@"message"];
            if([message isEqualToString:@"success"]) {
                // login success
                [NSUserDefaults.standardUserDefaults setObject:collectionId forKey:@"SignChatLoginCollectionID"];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                TableViewController* tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"tableViewController"];
                tableViewController.collectionId = collectionId;
                
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [viewController.navigationController setViewControllers:@[tableViewController] animated:YES];
                }];
                
            } else {
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:message title:@"Fail" sender:viewController];
                }];
            }
            
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message: @"Connection error."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [viewController presentViewController:alert animated:YES completion:nil];
        }
        
    }];
    [dataTask resume];
}

- (void) translate:(NSArray*) frames
    ofCollectionId:(NSString*) collectionId
            sender: (UIViewController*) viewController
{
    MessageHelper *helper = [[MessageHelper alloc] init];
    TranslateResultViewController* translateResultVC = viewController;
    
    NSString* url_str = [aiServiceURL_str stringByAppendingString:@"predict"];
    
    // prepare request data
    NSDictionary *dataPackage = [NSDictionary dictionaryWithObjectsAndKeys:
                                 collectionId, @"collectionId",
                                 frames, @"frames", nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataPackage options:NSJSONWritingSortedKeys error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSString* dataString = [NSString stringWithFormat:@"sign=%@",jsonString];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [helper alertMessage:[NSString stringWithFormat:@"%@",error] title:@"Error" dismissSender:translateResultVC];
            return;
        }
        if(httpResponse.statusCode == 200){
            error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            BOOL isSuccess = [response_dic objectForKey:@"success"];
            if(isSuccess) {

                NSArray *prediction = [response_dic objectForKey:@"prediction"];
                
                if(prediction.count>0) {
                    NSString *result = prediction[0];
                    for(int i = 1 ; i<prediction.count ; i++) {
                        result = [result stringByAppendingFormat:@" %@",prediction[i]];
                    }
                    result = [result stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[result substringToIndex:1] capitalizedString]];
                    translateResultVC.resultTextView.text = result;
                }
                NSLog(@"prediction: %@",prediction);
            } else {
                NSString *message = [response_dic objectForKey:@"message"];
                [helper alertMessage:message title:@"Error" dismissSender:translateResultVC];
            }
        } else {
            [helper alertMessage:@"Connection fail." title:@"Error" dismissSender:translateResultVC];
        }
    }];
    [dataTask resume];
}

- (void) getCollectionListWithSender: (UIViewController*) viewController
{
    CollectionListViewController *myViewController = viewController;
    MessageHelper *helper = [[MessageHelper alloc] init];
    
    NSString* url_str = [serverURL_str stringByAppendingFormat:@"getCollections.php"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [helper alertMessage:[NSString stringWithFormat:@"%@",error]
                           title:@"Error"
                   dismissSender:myViewController];
            return;
        }
        if(httpResponse.statusCode == 200){
            NSError* error = nil;
            NSArray *collectionList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [myViewController resetTable:collectionList];
        } else {
            [helper alertMessage:@"Connection fail."
                           title:@"Error"
                   dismissSender:myViewController];
        }
    }];
    [dataTask resume];
}

- (void) addSign:(NSDictionary*) sign
          sender: (UIViewController*) viewController
{
    MessageHelper *helper = [[MessageHelper alloc] init];
    UIAlertController* toastMessage = [helper showToastMessage: @"loading..." sender: viewController];
    
    NSError *error = nil;
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:sign options:NSJSONWritingPrettyPrinted error:&error];
    
    if(jsonObject!=nil && error == nil) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonObject encoding:NSUTF8StringEncoding];
        NSString* url_str = [serverURL_str stringByAppendingString:@"addSign.php"];
        
        // make request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
        NSString* dataString = [NSString stringWithFormat:@"sign=%@",jsonString];
        
        NSLog(@"Data:%@",dataString);
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];

        NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest: request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if(error!=nil) {
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:[NSString stringWithFormat:@"%@",error]
                                   title:@"Error"
                                  sender:viewController];
                }];
                return;
            }

            if(httpResponse.statusCode == 200)
            {
                NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

                NSString *message = [response_dic objectForKey:@"message"];
                NSString *title = [response_dic objectForKey:@"title"];

                NSString *collectionId = [response_dic objectForKey:@"collectionId"];

                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:message
                                   title:title
                           dismissSender:viewController];
                }];

            } else {
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:@"Connection fail."
                                   title:@"Error"
                                  sender:viewController];
                }];
            }
        }];
        [dataTask resume];

    } else {
//        [helper alertMessage: @"Fail to save your sign. Please try later."
//                       title: @"Fail"
//                      sender:viewController];
    }
}

- (void) getCollectionSignWithSender:(UIViewController*) viewController {
    TableViewController *myViewController = viewController;
    MessageHelper *helper = [[MessageHelper alloc] init];
    
    NSString* url_str = [serverURL_str stringByAppendingString:@"getSign.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [helper alertMessage:[NSString stringWithFormat:@"%@",error] title:@"Error" sender:myViewController];
            [self logoutFromSender:myViewController];
            return;
        }
        
        if(httpResponse.statusCode == 200){
            error = nil;
            NSDictionary* sign_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSString *collectionName = [sign_dic objectForKey:@"name"];
            if(collectionName==nil) {
                [helper alertMessage:@"Please login again." title:@"Session Timeout" sender:myViewController];
                [self logoutFromSender:myViewController];
                return;
            }
            
            myViewController.title = collectionName;
            NSArray *signData = [sign_dic objectForKey:@"sign"];
            [myViewController resetTable:signData];
            
        } else {
            [helper alertMessage:@"Connection fail." title:@"Error" sender:myViewController];
            [self logoutFromSender:myViewController];
        }
    }];
    [dataTask resume];
}

- (void) logoutFromSender: (UIViewController*) viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* translateCameraView = [storyboard instantiateViewControllerWithIdentifier:@"translateCameraView"];
    [viewController.navigationController setViewControllers:@[translateCameraView] animated:YES];
}

- (void) displaySignMotionPageByMeaning:(NSString*) meaning sender: (UIViewController*) viewController {
    TableViewController *tableViewController = viewController;
    NSString *collectionId = tableViewController.collectionId;
    
    MessageHelper *helper = [[MessageHelper alloc] init];
    UIAlertController* toastMessage = [helper showToastMessage: @"loading..." sender: viewController];
    
    NSString* url_str = [serverURL_str stringByAppendingFormat:@"getFrames.php?meaning=%@&collectionId=%@",meaning,collectionId];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [helper alertMessage:[NSString stringWithFormat:@"%@",error]
                               title:@"Error"
                              sender: viewController];
            }];
            return;
        }
        if(httpResponse.statusCode == 200){
            NSError* error = nil;
            NSArray* motion_arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SignMotionViewController *signMotionView = [storyboard instantiateViewControllerWithIdentifier:@"signMotionView"];
            signMotionView.motions = [NSMutableArray arrayWithArray:motion_arr];
            
            signMotionView.meaning = meaning;
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [viewController.navigationController showViewController:signMotionView sender:self];
            }];
        } else {
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [helper alertMessage:@"Connection fail." title:@"Error" sender: viewController];
            }];
        }
    }];
    [dataTask resume];
}

- (void) removeSignBySignId:(int) signId sender: (UIViewController*) viewController {
    SignMotionViewController *signMotionVC = viewController;
    
    MessageHelper *helper = [[MessageHelper alloc] init];
    UIAlertController* toastMessage = [helper showToastMessage: @"loading..." sender: viewController];
    
    NSString* url_str = [serverURL_str stringByAppendingFormat:@"removeSign.php?signId=%d",signId];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [helper alertMessage:[NSString stringWithFormat:@"%@",error]
                               title:@"Error"
                              sender: viewController];
            }];
            
            return;
        }
        if(httpResponse.statusCode == 200){
            NSError* error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSString *message = [response_dic objectForKey:@"message"];
            if(message != nil) {
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:message title:@"Fail" sender: signMotionVC];
                }];
            } else {
                NSString *collectionId = [response_dic objectForKey:@"collectionId"];
                
                NSString *meaning = [response_dic objectForKey:@"meaning"];
                [self updateSignMotionViewOfMeaning:meaning
                                       collectionId:collectionId
                                             sender:signMotionVC
                                       toastMessage:toastMessage];
            }
        } else {
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [helper alertMessage:@"Connection fail." title:@"Error" sender: viewController];
            }];
        }
    }];
    [dataTask resume];
}

- (void) updateSignMotionViewOfMeaning:(NSString*) meaning
                          collectionId: (NSString*) collectionId
                                sender: (SignMotionViewController*) viewController
                          toastMessage:(UIAlertController*) toastMessage {
    
    MessageHelper *helper = [[MessageHelper alloc] init];
    
    NSString* url_str = [serverURL_str stringByAppendingFormat:@"getFrames.php?meaning=%@&collectionId=%@",meaning,collectionId];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [helper alertMessage:[NSString stringWithFormat:@"%@",error]
                               title:@"Error"
                              sender: viewController];
            }];
            return;
        }
        if(httpResponse.statusCode == 200){
            NSError* error = nil;
            NSArray* motion_arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                if(motion_arr.count>0) {
                    [viewController resetCollectionView:motion_arr];
                } else {
                    [viewController.navigationController popViewControllerAnimated:YES];
                }
            }];
            
        } else {
            [toastMessage dismissViewControllerAnimated:YES completion:^{
                [helper alertMessage:@"Connection fail." title:@"Error" sender: viewController];
            }];
        }
    }];
    [dataTask resume];
}

- (void) updateAIModelOfCollection:(NSString*) collectionId sender:(UIViewController*) viewController showMessage: (BOOL) showMsg {
    
    MessageHelper *helper = [[MessageHelper alloc] init];

    NSString* url_str = [aiServiceURL_str stringByAppendingFormat:@"train?collectionId=%@",collectionId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];

    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            NSString* message = [NSString stringWithFormat:@"AI model is not updated due to error: %@",error];
            if (showMsg) {
                [helper showToastMessage:message duration:2 sender:viewController];
            }
            return;
        }
        if(httpResponse.statusCode == 200){
            error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (showMsg) {
                BOOL isSuccess = [response_dic objectForKey:@"success"];
                if(!isSuccess) {
                    NSString* message = [response_dic objectForKey:@"message"];
                    [helper showToastMessage:[message stringByAppendingString:@" AI model is not updated."]
                                    duration:2
                                      sender:viewController];
                }
            }
        } else {
            if (showMsg) {
                [helper showToastMessage:@"AI model is not updated due to connection fail."
                                duration:2
                                  sender:viewController];
            }
        }
    }];
    [dataTask resume];
}

- (void) showModelInformationOf:(NSString*) collectionId sender:(UIViewController*) viewController {
    
    MessageHelper *helper = [[MessageHelper alloc] init];
    
    NSString* url_str = [aiServiceURL_str stringByAppendingFormat:@"modelInfo?collectionId=%@",collectionId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error!=nil) {
            NSString* message = [NSString stringWithFormat:@"AI model is not updated due to error: %@",error];
            return;
        }
        if(httpResponse.statusCode == 200){
            error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSDictionary *modelInfo = [response_dic objectForKey:@"modelInfo"];
            NSString *lastUpdate = [modelInfo objectForKey:@"lastUpdate"];
            NSString *accuracy = [modelInfo objectForKey:@"accuracy"];
            NSString *loss = [modelInfo objectForKey:@"loss"];
            NSString *val_accuracy = [modelInfo objectForKey:@"val_accuracy"];
            NSString *val_loss = [modelInfo objectForKey:@"val_loss"];
            [self showModelMessage:collectionId lastUpdate:lastUpdate accuracy:accuracy loss:loss val_accuracy:val_accuracy val_loss:val_loss sender:viewController];
            
            
        } else {
            [helper showToastMessage:@"AI model is not updated due to connection fail."
                            duration:2
                              sender:viewController];
        }
    }];
    [dataTask resume];
}

- (void) showModelMessage: (NSString*) collectionId
               lastUpdate: (NSString*) lastUpdate
                 accuracy: (NSString*) accuracy
                     loss: (NSString*) loss
             val_accuracy: (NSString*) val_accuracy
                 val_loss: (NSString*) val_loss
                   sender:(UIViewController*) viewController {
    NSString* title = [NSString stringWithFormat:@"%s\n%s", [@"Last update" UTF8String], [lastUpdate UTF8String]];
    NSString* message = [NSString stringWithFormat:@"\n%-13s%5s\n%-13s%5s\n%-13s%5s\n%-13s%5s",
                         [@"Accuracy" UTF8String], [accuracy UTF8String],
                         [@"Loss" UTF8String], [loss UTF8String],
                         [@"Val Accuracy" UTF8String], [val_accuracy UTF8String],
                         [@"Val loss" UTF8String], [val_loss UTF8String]];
    
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *trainModelBtn = [UIAlertAction actionWithTitle:@"Train Model"
                                                                  style:UIAlertActionStyleCancel
                                                                handler:^(UIAlertAction* action) {
        [self updateAIModelOfCollection:collectionId sender:viewController showMessage:YES];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [menu addAction:trainModelBtn];
    [menu addAction:cancelBtn];
    
    // set font
    UIFont *titleFont = [UIFont fontWithName:@"Courier" size:19.0];
    UIFont *messageFont = [UIFont fontWithName:@"Courier New" size:18.0];
    NSMutableAttributedString *titleAttrString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: titleFont}];
    NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: messageFont}];
    [menu setValue:titleAttrString forKey: @"attributedTitle"];
    [menu setValue:messageAttrString forKey: @"attributedMessage"];
    
    [viewController presentViewController:menu animated:YES completion:nil];
}


- (void) setCollectionInformation: (UIViewController*) sender {
    InfoUpdateViewController *viewController = sender;
    NSString *collectionId = viewController.collectionId;
    
    NSString* url_str = [serverURL_str stringByAppendingFormat:@"getSignCollection.php?collectionId=%@",collectionId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200){
            NSError* error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            SignCollection *sc = [[SignCollection alloc] init];
            sc.collectionId = collectionId;
            sc.organisationId = [((NSString *)[response_dic objectForKey:@"organisationId"]) intValue];
            sc.name = [response_dic objectForKey:@"name"];
            sc.contactPerson = [response_dic objectForKey:@"contactPerson"];
            sc.contactPersonTitle = [response_dic objectForKey:@"contactPersonTitle"];
            sc.contactPersonEmail = [response_dic objectForKey:@"contactPersonEmail"];
            sc.contactPersonTel = [response_dic objectForKey:@"contactPersonTel"];
            
            [viewController setCollectionInformation: sc];
        }
    }];
    
    [dataTask resume];
}

- (void) setOrganisationInformation: (UIViewController*) sender organisationId: (NSInteger) organisationId {
    InfoUpdateViewController *viewController = sender;
    
    NSString* url_str = [serverURL_str stringByAppendingFormat:@"getOrganisation.php?organisationId=%d",organisationId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    
    NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200){
            NSError* error = nil;
            NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            Organisation *o = [[Organisation alloc] init];
            o.organisationId = [((NSString *)[response_dic objectForKey:@"organisationId"]) intValue];
            o.name = [response_dic objectForKey:@"name"];
            o.email = [response_dic objectForKey:@"email"];
            o.address = [response_dic objectForKey:@"address"];
            o.tel = [response_dic objectForKey:@"tel"];
            o.collectionCount = [(NSString*)[response_dic objectForKey:@"collectionCount"] intValue];
            
            [viewController setOrganisationInformation: o];
        }
    }];
    
    [dataTask resume];
}

- (void) updateCollectionInformation: (SignCollection*) signcollection
                        organisation: (Organisation*) organisation
                      verifyPassword: (NSString*) verifyPassword
                              sender: (UIViewController*) viewController {
    
    MessageHelper *helper = [[MessageHelper alloc] init];
    UIAlertController* toastMessage = [helper showToastMessage: @"loading..." sender: viewController];
    
    NSDictionary *info = @{
        @"organisation":[organisation convertToDictionary],
        @"collection":[signcollection convertToDictionary],
        @"verifyPassword":verifyPassword
    };
    
    NSError *error = nil;
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    
    if(jsonObject!=nil && error == nil) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonObject encoding:NSUTF8StringEncoding];
        NSString* url_str = [serverURL_str stringByAppendingString:@"updateInfo.php"];
        
        // make request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
        NSString* dataString = [NSString stringWithFormat:@"info=%@",jsonString];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"%@",dataString);
        
        NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithRequest: request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if(error!=nil) {
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:[NSString stringWithFormat:@"%@",error]
                                   title:@"Error"
                                  sender:viewController];
                }];
                return;
            }
            
            if(httpResponse.statusCode == 200)
            {
                
                NSDictionary *response_dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                NSLog(@"%@",response_dic);
                
                NSString *message = [response_dic objectForKey:@"message"];
                
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    if(message.length > 0) {
                        [helper alertMessage:message
                                       title:@"Fail"
                                      sender:viewController];
                    } else {
                        [viewController.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
            } else {
                [toastMessage dismissViewControllerAnimated:YES completion:^{
                    [helper alertMessage:@"Connection fail."
                                   title:@"Error"
                                  sender:viewController];
                }];
            }
        }];
        [dataTask resume];
        
    }
}

@end
