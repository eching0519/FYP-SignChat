//
//  Organisation.m
//  _idx_ObjectDetectionGpuAppLibrary_EdgeDetectionGpuAppLibrary_FaceDetectionCpuAppLibrary_FaceDetectionGpuAppLibrary_HandDetectionGpuAppLibrary_HandTrackingGpuAppLibrary_MultiHandTrac_etc_01926E23_ios_min10.0
//
//  Created by Yee Ching Ng on 18/3/2020.
//

#import "Organisation.h"

@implementation Organisation

@synthesize organisationId, name, email, address, tel, collectionCount, collections;

- (NSDictionary*) convertToDictionary {
    return @{
        @"organisationId":[NSNumber numberWithInteger:organisationId],
        @"name":(name==nil)?@"":name,
        @"email":(email==nil)?@"":email,
        @"address":(address==nil)?@"":address,
        @"tel":(tel==nil)?@"":tel
    };
}

@end
