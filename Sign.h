//
//  Sign.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 31/3/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Sign : NSObject

@property (assign) NSInteger *signId;
@property (strong, retain) NSString *collectionId;
@property (strong, retain) NSString *meaning;

@end

NS_ASSUME_NONNULL_END
