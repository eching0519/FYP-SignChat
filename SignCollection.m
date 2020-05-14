//
//  SignCollection.m
//  _idx_ObjectDetectionGpuAppLibrary_EdgeDetectionGpuAppLibrary_FaceDetectionCpuAppLibrary_FaceDetectionGpuAppLibrary_HandDetectionGpuAppLibrary_HandTrackingGpuAppLibrary_MultiHandTrac_etc_01926E23_ios_min10.0
//
//  Created by Yee Ching Ng on 18/3/2020.
//

#import "SignCollection.h"

@implementation SignCollection

@synthesize organisationId, collectionId, name, password, contactPerson, contactPersonTitle, contactPersonEmail, contactPersonTel, signs;

- (NSDictionary*) convertToDictionary {
    return @{
        @"organisationId":[NSNumber numberWithInteger:organisationId],
        @"collectionId":(collectionId==nil)?@"":collectionId,
        @"name":(name==nil)?@"":name,
        @"password":(password==nil)?@"":password,
        @"contactPerson":(contactPerson==nil)?@"":contactPerson,
        @"contactPersonTitle":(contactPersonTitle==nil)?@"":contactPersonTitle,
        @"contactPersonEmail":
            (contactPersonEmail==nil)?@"":contactPersonEmail,
        @"contactPersonTel":(contactPersonTel==nil)?@"":contactPersonTel
    };
}

@end
