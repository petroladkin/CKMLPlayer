//
//  DevicesViewController.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 15.05.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "DevicesViewController.h"
#import "DeviceTableViewCell.h"
#import "DeviceManager.h"


@interface DevicesViewController () <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIActivityIndicatorView* busyIndicator;
@property (strong, nonatomic) UIRefreshControl* tableRefreshControl;

@property (strong, nonatomic) NSArray* devices;

@end


@implementation DevicesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.tableRefreshControl];
    [self.tableRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.busyIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.busyIndicator];
    
    self.devices = @[];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(deviceManagerWillUpdateDeviceList:) name:DeviceManagerWillUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerDidUpdateDeviceList:) name:DeviceManagerDidUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerFailUpdateDeviceList:) name:DeviceManagerFailUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerTimeoutUpdateDeviceList:) name:DeviceManagerTimeoutUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerDidUpdateDeviceInfo:) name:DeviceManagerDidUpdateDeviceInfo object:nil];
    
    [[DeviceManager sharedManager] updateDeviceList];
}


#pragma mark - notifications

- (void)deviceManagerWillUpdateDeviceList:(NSNotification*)notification {
    if (!self.tableRefreshControl.refreshing) {
        [self.busyIndicator startAnimating];
    }
}

- (void)deviceManagerDidUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];
    
    self.devices = [NSArray arrayWithArray:[DeviceManager sharedManager].devices];
    
    [self.tableView reloadData];
}

- (void)deviceManagerFailUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];

    self.devices = @[];
    
    [self.tableView reloadData];
}

- (void)deviceManagerTimeoutUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];
    
    self.devices = @[];
    
    [self.tableView reloadData];
}

- (void)deviceManagerDidUpdateDeviceInfo:(NSNotification*)notification {
    self.devices = [NSArray arrayWithArray:[DeviceManager sharedManager].devices];
    [self.tableView reloadData];
}


#pragma mark - events

- (void)refreshTable {
    [[DeviceManager sharedManager] updateDeviceList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellDevice = @"cellDevice";
    
    DeviceInfo* di = [self.devices objectAtIndex:indexPath.row];
    
    DeviceTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellDevice];

    [cell update:di];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
