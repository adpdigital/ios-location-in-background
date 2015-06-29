//
//  LocationCenter.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "LocationCenter.h"
#import <CoreLocation/CoreLocation.h>
#import "WeakList.h"

static LocationCenter* sharedInstance = nil;

static NSString* kRegionMonitorID = @"co.gongch.lab.BgTracker.defaultRegion";

@interface LocationCenter () <CLLocationManagerDelegate>
- (instancetype)init;
- (NSString*)datafilePath;
@property (strong) CLLocationManager *locationManager;
@property (strong) NSDate *lastUpdateTime;
@end


@implementation LocationCenter {
    LCMonitoringType _monitoringType;
    NSString *_datafilePath;
    NSMutableArray *_locationRecords;
    BOOL _dataDirty;
    WeakList *_delegates;
}

+ (LocationCenter*)sharedLocationCenter {
    if (sharedInstance == nil) {
        sharedInstance = [[LocationCenter alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _monitoringType = LCNotMonitoring;
        _lastUpdateTime = nil;
        _datafilePath = nil;
        _locationRecords = nil;
        _dataDirty = NO;
        _delegates = [[WeakList alloc] init];
    }
    return self;
}

#pragma mark - Location Service

- (void)prepare {
    if (self.isReady) {
        NSLog(@"LocationCenter is already ready :p");
        return;
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self requestLocationAuthorization];
    
    if (_locationRecords == nil) {
        NSMutableArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self datafilePath]];
        _locationRecords = [[NSMutableArray alloc] init];
        if (array != nil) {
            [_locationRecords addObjectsFromArray:array];
            NSLog(@"LocationCenter loaded %ld records", (unsigned long) array.count);
        } else {
            NSLog(@"LocationCenter loaded 0 record");
        }
    }
    
    if (self.isReady) {
        NSLog(@"LocationCenter is ready :)");
    }
}

- (BOOL)isReady {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status == kCLAuthorizationStatusAuthorizedAlways && _locationRecords != nil;
}

- (void)requestLocationAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager requestAlwaysAuthorization];
        if (self.isReady) {
            NSLog(@"Authorization OK ;)");
        } else {
            NSLog(@"Authorization Failed x_x");
        }
    }
}

- (void)startForegroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LCForegroundMonitoring) {
            return;
        } else if (_monitoringType == LCBackgroundMonitoring) {
            [self stopBackgroundUpdating];
        }
        [self.locationManager startUpdatingLocation];
        _monitoringType = LCForegroundMonitoring;
        NSLog(@"LocationCenter foreground start!");
    }
}

- (void)stopForegroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LCForegroundMonitoring) {
            [self.locationManager stopUpdatingLocation];
            _monitoringType = LCNotMonitoring;
            NSLog(@"LocationCenter foreground stop!");
        }
    }
}

- (void)startBackgroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LCBackgroundMonitoring) {
            return;
        } else if (_monitoringType == LCForegroundMonitoring) {
            [self stopForegroundUpdating];
        }
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startMonitoringVisits];
        _monitoringType = LCBackgroundMonitoring;
        NSLog(@"LocationCenter background start!");
    }
}

- (void)stopBackgroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LCBackgroundMonitoring) {
            [self.locationManager stopMonitoringSignificantLocationChanges];
            [self.locationManager stopMonitoringVisits];
            _monitoringType = LCNotMonitoring;
            NSLog(@"LocationCenter background stop!");
        }
    }
}

- (LCMonitoringType)monitoringType {
    return _monitoringType;
}

- (void)addDelegate:(id <LocationCenterDelegate>)delegate {
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id <LocationCenterDelegate>)delegate {
    [_delegates removeObject:delegate];
}

#pragma mark - Region Monitoring

- (CLRegion*)currentMonitoredRegion {
    __block CLRegion *region = nil;
    [self.locationManager.monitoredRegions enumerateObjectsUsingBlock:^(__kindof CLRegion * __nonnull obj, BOOL * __nonnull stop) {
        if ([obj.identifier isEqualToString:kRegionMonitorID]) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (void)resetRegionMonitorToLocation:(LocationRecord*)loc {
    [self clearRegionMonitor];
    
    CLLocationDistance radius = 100.0; // m
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter:loc.coordinate
                                   radius:radius
                                   identifier:kRegionMonitorID];
    geoRegion.notifyOnEntry = NO;
    geoRegion.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:geoRegion];
    
    NSLog(@"setup region monitor");
}

- (BOOL)clearRegionMonitor {
    CLRegion *region = self.currentMonitoredRegion;
    if (region != nil) {
        [self.locationManager stopMonitoringForRegion:region];
        NSLog(@"clear region monitor");
        return YES;
    } else {
        return NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    
    if (self.lastUpdateTime != nil) {
        if ([location.timestamp timeIntervalSinceDate:self.lastUpdateTime] < 10.0) {
            // just update in 10 sec. ignore this event.
            return;
        }
    }
    
    LocationRecord *record = [[LocationRecord alloc] initWithCLLocation:location
                                                         monitoringType:self.monitoringType];
    self.lastUpdateTime = record.timestamp;
    NSLog(@"%@", record);
    
    [_locationRecords insertObject:record atIndex:0];
    [self notifyInsertAtIndex:0];
    
    if (self.monitoringType == LCBackgroundMonitoring) {
        // save data in background
        [self saveData];
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    if ([region.identifier isEqualToString:kRegionMonitorID]) {
        CLCircularRegion *circularRegion = (CLCircularRegion *) region;
        LocationRecord *record = [[LocationRecord alloc] initWithCLCoordinate2D:circularRegion.center
                                                                 monitoringType:LCExitRegion];
        
        [_locationRecords insertObject:record atIndex:0];
        [self notifyInsertAtIndex:0];
        
        if (self.monitoringType == LCBackgroundMonitoring) {
            // save data in background
            [self saveData];
        }

        NSLog(@"exit region!");
        [self clearRegionMonitor];
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didVisit:(nonnull CLVisit *)visit {
    LocationRecord *record = [[LocationRecord alloc] initWithCLCoordinate2D:visit.coordinate
                                                             monitoringType:LCVisitedLocation];
    [_locationRecords insertObject:record atIndex:0];
    [self notifyInsertAtIndex:0];
    
    if (self.monitoringType == LCBackgroundMonitoring) {
        // save data in background
        [self saveData];
    }
    
    NSLog(@"visited: %@", record);
}

#pragma mark - Location Data

- (NSString*)datafilePath {
    if (_datafilePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _datafilePath = [documentsDirectory stringByAppendingPathComponent:@"location_data"];
    }
    return _datafilePath;
}

- (NSArray*)locationRecords {
    return _locationRecords;
}

- (BOOL)isDataDirty {
    return _dataDirty;
}

- (void)notifyInsertAtIndex:(NSUInteger)index {
    if (!_dataDirty) {
        _dataDirty = YES;
    }
    
    [_delegates forEach:^(id object) {
        id <LocationCenterDelegate> delegate = object;
        if ([delegate respondsToSelector:@selector(locationCenter:didInsertRecordAtIndex:)]) {
            [delegate locationCenter:self didInsertRecordAtIndex:index];
        }
    }];
}

- (void)clearAllData {
    if (_locationRecords.count > 0) {
        [_locationRecords removeAllObjects];
        _dataDirty = YES;
        NSLog(@"LocationCenter data clear!");
        [_delegates forEach:^(id object) {
            id <LocationCenterDelegate> delegate = object;
            if ([delegate respondsToSelector:@selector(locationCenterDidClearAllData:)]) {
                [delegate locationCenterDidClearAllData:self];
            }
        }];
    }
}

- (void)saveData {
    if (_dataDirty) {
        [NSKeyedArchiver archiveRootObject:_locationRecords toFile:[self datafilePath]];
        _dataDirty = NO;
        NSLog(@"LocationCenter saved %ld records", (unsigned long) _locationRecords.count);
    } else {
        NSLog(@"LocationCenter no record to save");
    }
}

@end
