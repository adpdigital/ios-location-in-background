//
//  MapViewController.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/22.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "LocationCenter.h"

@interface MapViewController () <MKMapViewDelegate, LocationCenterDelegate>
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) LocationCenter *locationCenter;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationCenter = [LocationCenter sharedLocationCenter];
    [self.mapView addAnnotations:self.locationCenter.locationRecords];

//    self.mapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSArray *records = self.locationCenter.locationRecords;
    if (records.count > 0) {
        [self moveToRecord:records[0]];
    }
}

- (void)moveToRecord:(LocationRecord*)record {
    MKCoordinateRegion region = MKCoordinateRegionMake(record.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    [self.mapView setRegion:region animated:YES];
}

- (void)locationCenter:(LocationCenter*)locationCenter didInsertRecordAtIndex:(NSUInteger)index {
    [self.mapView addAnnotation:self.locationCenter.locationRecords[index]];
}

- (void)locationCenterDidClearAllData:(LocationCenter*)locationCenter {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (nullable MKAnnotationView *)mapView:(nonnull MKMapView *)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[LocationRecord class]]) {
        MKPinAnnotationView *view = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pin_view"];
        if (view == nil) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin_view"];
            view.canShowCallout = YES;
        } else {
            view.annotation = annotation;
        }
        return view;
    }
    
    return nil;
}

@end
