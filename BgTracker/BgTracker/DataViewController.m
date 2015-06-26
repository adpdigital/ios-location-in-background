//
//  DataViewController.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "DataViewController.h"
#import "LocationCenter.h"

@interface DataViewController () <LocationCenterDelegate>
@property (strong) LocationCenter *locationCenter;
@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationCenter = [LocationCenter sharedLocationCenter];
    [self.locationCenter addDelegate:self];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.locationCenter.isReady == NO) {
        return 0;
    } else {
        return self.locationCenter.locationRecords.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationRecord *record = self.locationCenter.locationRecords[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"location_cell"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *labelData = [dateFormatter stringFromDate:record.timestamp];
    
    cell.textLabel.text = labelData;
    if (record.type == LCBackgroundMonitoring) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (SCLS)", record];
    } else if (record.type == LCExitRegion) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (Exit Region)", record];
    } else if (record.type == LCVisitedLocation) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (Visited Location)", record];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", record];
    }
    
    return cell;
}

- (BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(nonnull UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    __weak DataViewController *weakSelf = self;
    
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Monitor Here" handler:^(UITableViewRowAction * __nonnull action, NSIndexPath * __nonnull indexPath) {
        
        LocationRecord *record = weakSelf.locationCenter.locationRecords[indexPath.row];
        [weakSelf.locationCenter resetRegionMonitorToLocation:record];
        
        [weakSelf.tableView setEditing:NO animated:YES];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Region Monitoring"
                                                                            message:@"This location is being monitoring."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * __nonnull action) {}]];
        
        [self presentViewController:controller animated:YES completion:^{}];
    }];
    action.backgroundColor = [UIColor purpleColor];
    
    return @[ action ];
}

#pragma mark - Location Delegate

- (void)locationCenter:(LocationCenter*)locationCenter didInsertRecordAtIndex:(NSUInteger)index {
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)locationCenterDidClearAllData:(LocationCenter *)locationCenter {
    [self.tableView reloadData];
}

#pragma mark - UI Delegate

- (IBAction)clearItemAction:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Clear All Data"
                                                                        message:@"Really clear all data?"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Yes"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * __nonnull action) {
        [self.locationCenter clearAllData];
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * __nonnull action) {
    }]];
    
    [self presentViewController:controller animated:YES completion:^{}];
}

@end
