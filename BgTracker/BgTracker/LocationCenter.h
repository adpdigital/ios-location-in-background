//
//  LocationCenter.h
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationRecord.h"


@class LocationCenter;

@protocol LocationCenterDelegate <NSObject>
@optional
- (void)locationCenter:(LocationCenter*)locationCenter didInsertRecordAtIndex:(NSUInteger)index;
- (void)locationCenterDidClearAllData:(LocationCenter*)locationCenter;
@end

@interface LocationCenter : NSObject

+ (LocationCenter*)sharedLocationCenter;

- (void)prepare;
- (void)startForegroundUpdating;
- (void)stopForegroundUpdating;
- (void)startBackgroundUpdating;
- (void)stopBackgroundUpdating;

- (void)clearAllData;
- (void)saveData;

- (void)addDelegate:(id <LocationCenterDelegate>)delegate;
- (void)removeDelegate:(id <LocationCenterDelegate>)delegate;

- (void)resetRegionMonitorToLocation:(LocationRecord*)loc;
- (BOOL)clearRegionMonitor;

@property (readonly) BOOL isReady;
@property (readonly) BOOL isDataDirty;
@property (readonly) LCMonitoringType monitoringType;

@property (readonly) NSArray *locationRecords;
@property (readonly) CLRegion *currentMonitoredRegion;

@end
