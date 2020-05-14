//
//  Organisation.h
//  _idx_ObjectDetectionGpuAppLibrary_EdgeDetectionGpuAppLibrary_FaceDetectionCpuAppLibrary_FaceDetectionGpuAppLibrary_HandDetectionGpuAppLibrary_HandTrackingGpuAppLibrary_MultiHandTrac_etc_01926E23_ios_min10.0
//
//  Created by Yee Ching Ng on 18/3/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Organisation : NSObject

@property (assign) NSInteger *organisationId;
@property (strong, retain) NSString *name;
@property (strong, retain) NSString *email;
@property (strong, retain) NSString *address;
@property (strong, retain) NSString *tel;

@property (assign) NSInteger *collectionCount;
@property (strong, retain) NSArray *collections;

- (NSDictionary*) convertToDictionary;

@end

NS_ASSUME_NONNULL_END
