//
//  MessageHelper.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 4/2/2020.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHelper : NSObject

- (void) showToastMessage: (NSString*) message
                 duration:(float) duration
                   sender:(UIViewController*) viewController;

- (UIAlertController*) showToastMessage: (NSString*) message
                                 sender:(UIViewController*) viewController;

- (void) alertMessage: (NSString*) message
                title: (NSString*) title
               sender:(UIViewController*) viewController;

- (void) alertMessage: (NSString*) message
                title: (NSString*) title
        dismissSender:(UIViewController*) viewController;


@end

NS_ASSUME_NONNULL_END
