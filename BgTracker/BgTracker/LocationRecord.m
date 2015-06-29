//
//  LocationRecord.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "LocationRecord.h"
#import "LocationCenter.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationRecord ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation LocationRecord {
    CLLocationCoordinate2D _coordinate;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithCLLocation:(CLLocation*)location monitoringType:(LCMonitoringType)type {
    if (self = [super init]) {
        self.timestamp = location.timestamp;
        self.type = type;
        self.latitude = location.coordinate.latitude;
        self.longitude = location.coordinate.longitude;
        self.altitude = location.altitude;
        _coordinate.latitude = self.latitude;
        _coordinate.longitude = self.longitude;
    }
    return self;
}

- (instancetype)initWithCLCoordinate2D:(CLLocationCoordinate2D)coordinate monitoringType:(LCMonitoringType)type {
    if (self = [super init]) {
        self.timestamp = [NSDate date];
        self.type = type;
        self.latitude = coordinate.latitude;
        self.longitude = coordinate.longitude;
        self.altitude = 0.0;
        _coordinate.latitude = self.latitude;
        _coordinate.longitude = self.longitude;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
        self.type = [decoder decodeIntegerForKey:@"type"];
        self.latitude = [decoder decodeDoubleForKey:@"latitude"];
        self.longitude = [decoder decodeDoubleForKey:@"longitude"];
        self.altitude = [decoder decodeDoubleForKey:@"altitude"];
        _coordinate.latitude = self.latitude;
        _coordinate.longitude = self.longitude;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    [encoder encodeInteger:self.type forKey:@"type"];
    [encoder encodeDouble:self.latitude forKey:@"latitude"];
    [encoder encodeDouble:self.longitude forKey:@"longitude"];
    [encoder encodeDouble:self.altitude forKey:@"altitude"];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    LocationRecord *record = [[LocationRecord alloc] init];
    record.timestamp = self.timestamp;
    record.type = self.type;
    record.latitude = self.latitude;
    record.longitude = self.longitude;
    record.altitude = self.altitude;
    record->_coordinate.latitude = self.latitude;
    record->_coordinate.longitude = self.longitude;
    return record;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Lat=%+.4f,Lng=%+.4f]", self.latitude, self.longitude];
}

- (NSString *)locationDescription {
    if (self.type == LCBackgroundMonitoring) {
        return [NSString stringWithFormat:@"%@ (SCLS)", self.description];
    } else if (self.type == LCExitRegion) {
        return [NSString stringWithFormat:@"%@ (Exit Region)", self.description];
    } else if (self.type == LCVisitedLocation) {
        return [NSString stringWithFormat:@"%@ (Visited Location)", self.description];
    } else {
        return [NSString stringWithFormat:@"%@", self.description];
    }
}

#pragma mark - MKAnnotaion

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D result = _coordinate;
    // HuoXing Magic
    result.latitude += 0.0015;
    result.longitude += 0.00625;
    return result;
}

- (NSString *)title {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:self.timestamp];
}

- (NSString *)subtitle {
    return self.locationDescription;
}

@end
