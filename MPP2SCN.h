//
//  MPP2SCN.h
//  Mediapipe
//
//  Created by Yee Ching Ng on 19/1/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPP2SCN : NSObject

- (float) convertX: (float)x;

- (float) convertXWhenMirroring: (float)x;

- (float) convertY: (float)y;

- (float) convertZ: (float) z root_z: (float) root_z;

@end

NS_ASSUME_NONNULL_END
