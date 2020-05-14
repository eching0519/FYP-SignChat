//
//  MessageHelper.m
//  Mediapipe
//
//  Created by Yee Ching Ng on 4/2/2020.
//

#import "MessageHelper.h"

@implementation MessageHelper

- (void) showToastMessage: (NSString*) message
                 duration:(float) duration
                   sender:(UIViewController*) viewController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    [viewController presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (UIAlertController*) showToastMessage: (NSString*) message
                                 sender:(UIViewController*) viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    [viewController presentViewController:alert animated:YES completion:nil];
    return alert;
}

- (void) alertMessage: (NSString*) message title: (NSString*) title sender:(UIViewController*) viewController {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message: message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void) alertMessage: (NSString*) message title: (NSString*) title dismissSender:(UIViewController*) viewController {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message: message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        //[viewController dismissViewControllerAnimated:YES completion:nil];
        [viewController.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction:defaultAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}


@end
