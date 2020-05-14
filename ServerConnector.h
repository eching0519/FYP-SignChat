//
//  ServerConnector.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 4/2/2020.
//

#import <UIKit/UIKit.h>
#import "Organisation.h"
#import "SignCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServerConnector : NSObject<NSURLSessionDelegate>

- (void) loginCollectionId: (NSString*) collectionId
                  password: (NSString*) password
                    sender: (UIViewController*) viewController;

- (void) translate:(NSArray*) frames
    ofCollectionId:(NSString*) collectionId
            sender: (UIViewController*) viewController;

- (void) getCollectionListWithSender: (UIViewController*) viewController;

- (void) addSign:(NSDictionary*) sign
          sender: (UIViewController*) viewController;

- (void) getCollectionSignWithSender:(UIViewController*) viewController;

- (void) displaySignMotionPageByMeaning:(NSString*) meaning sender: (UIViewController*) viewController;

- (void) removeSignBySignId:(int) signId sender: (UIViewController*) viewController;

- (void) updateAIModelOfCollection:(NSString*) collectionId
                            sender:(UIViewController*) viewController
                       showMessage: (BOOL) showMsg;

- (void) showModelInformationOf:(NSString*) collectionId sender:(UIViewController*) viewController;

- (void) setCollectionInformation: (UIViewController*) sender;

- (void) setOrganisationInformation: (UIViewController*) sender organisationId: (NSInteger) organisationId;

- (void) updateCollectionInformation: (SignCollection*) signcollection
                        organisation: (Organisation*) organisation
                      verifyPassword: (NSString*) verifyPassword
                              sender: (UIViewController*) viewController;

@end

NS_ASSUME_NONNULL_END
