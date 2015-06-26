//
//  LocationRecord.h
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


typedef enum : NSInteger {
    LCNotMonitoring = 0,
    LCForegroundMonitoring = 1,
    LCBackgroundMonitoring = 2,
    LCExitRegion = 3,
    LCVisitedLocation = 4,
} LCMonitoringType;

@class CLLocation;

@interface LocationRecord : NSObject <NSCoding, NSCopying, MKAnnotation>

- (instancetype)init;
- (instancetype)initWithCLLocation:(CLLocation*)location monitoringType:(LCMonitoringType)type;
- (instancetype)initWithCLCoordinate2D:(CLLocationCoordinate2D)coordinate monitoringType:(LCMonitoringType)type;

@property (strong) NSDate *timestamp;
@property (assign) LCMonitoringType type;
@property (assign) double latitude;
@property (assign) double longitude;
@property (assign) double altitude;

@end
