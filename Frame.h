//
//  Frame.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 31/3/2020.
//

#import <Foundation/Foundation.h>
#import "Landmark.h"

NS_ASSUME_NONNULL_BEGIN

@interface Frame : NSObject

@property (assign) NSInteger *signId;
@property (assign) NSInteger *sequenceNo;
@property (assign) CGFloat *root_z;
@property (strong, retain) NSArray<Landmark*> *leftLandmarks;
@property (strong, retain) NSArray<Landmark*> *rightLandmarks;

@end

NS_ASSUME_NONNULL_END
