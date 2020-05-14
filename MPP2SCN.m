//
//  MPP2SCN.m
//  Mediapipe
//
//  Created by Yee Ching Ng on 19/1/2020.
//

#import "MPP2SCN.h"

@implementation MPP2SCN

- (float) convertX: (float)x {
    return x*9;
}

- (float) convertXWhenMirroring: (float)x {
    return -x*9;
}

- (float) convertY: (float)y {
    return -y*17;
}

- (float) convertZ: (float) z root_z: (float) root_z {
    if(z==root_z) {
        return -z;
    } else {
        return -(root_z+z)/15;
    }
}

@end
