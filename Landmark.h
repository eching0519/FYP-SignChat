//
//  Landmark.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 31/3/2020.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Landmark : NSObject

@property (assign) CGFloat *x;
@property (assign) CGFloat *y;
@property (assign) CGFloat *z;

@end

NS_ASSUME_NONNULL_END
