//
//  SignCollection.h
//  _idx_ObjectDetectionGpuAppLibrary_EdgeDetectionGpuAppLibrary_FaceDetectionCpuAppLibrary_FaceDetectionGpuAppLibrary_HandDetectionGpuAppLibrary_HandTrackingGpuAppLibrary_MultiHandTrac_etc_01926E23_ios_min10.0
//
//  Created by Yee Ching Ng on 18/3/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignCollection : NSObject

@property (assign) NSInteger *organisationId;
@property (strong, retain) NSString *collectionId;
@property (strong, retain) NSString *name;
@property (strong, retain) NSString *password;

@property (strong, retain) NSString *contactPerson;
@property (strong, retain) NSString *contactPersonTitle;
@property (strong, retain) NSString *contactPersonEmail;
@property (strong, retain) NSString *contactPersonTel;

@property (strong, retain) NSArray *signs;

- (NSDictionary*) convertToDictionary;

@end

NS_ASSUME_NONNULL_END
