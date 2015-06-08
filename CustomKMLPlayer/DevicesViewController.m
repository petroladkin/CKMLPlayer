//
//  DevicesViewController.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 15.05.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "DevicesViewController.h"
#import "FileSystemViewController.h"
#import "DeviceTableViewCell.h"
#import "KWMLDeviceManager.h"
#import "WebDavFileSystem.h"

#import "InMemmoryCoreDataManager.h"


@interface DevicesViewController () <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIActivityIndicatorView* busyIndicator;
@property (strong, nonatomic) UIRefreshControl* tableRefreshControl;

@property (strong, nonatomic) NSArray* kwmlDevices;
@property (strong, nonatomic) NSArray* localStorages;

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
    
    self.kwmlDevices = @[];
    self.localStorages = @[];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(deviceManagerWillUpdateDeviceList:) name:DeviceManagerWillUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerDidUpdateDeviceList:) name:DeviceManagerDidUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerFailUpdateDeviceList:) name:DeviceManagerFailUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerTimeoutUpdateDeviceList:) name:DeviceManagerTimeoutUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerDidUpdateDeviceInfo:) name:DeviceManagerDidUpdateDeviceInfo object:nil];
    
    [[KWMLDeviceManager sharedManager] updateDeviceList];
}


#pragma mark - notifications

- (void)deviceManagerWillUpdateDeviceList:(NSNotification*)notification {
//    if (!self.tableRefreshControl.refreshing) {
//        [self.busyIndicator startAnimating];
//    }
}

- (void)deviceManagerDidUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];
    
    self.kwmlDevices = [NSArray arrayWithArray:[KWMLDeviceManager sharedManager].devices];
    
    [self.tableView reloadData];
}

- (void)deviceManagerFailUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];

    self.kwmlDevices = @[];
    
    [self.tableView reloadData];
}

- (void)deviceManagerTimeoutUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];
    
    self.kwmlDevices = @[];
    
    [self.tableView reloadData];
}

- (void)deviceManagerDidUpdateDeviceInfo:(NSNotification*)notification {
    self.kwmlDevices = [NSArray arrayWithArray:[KWMLDeviceManager sharedManager].devices];
    [self.tableView reloadData];
}


#pragma mark - events

- (void)refreshTable {
    [[KWMLDeviceManager sharedManager] updateDeviceList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.kwmlDevices.count + self.localStorages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellDevice = @"cellDevice";
    static NSString* cellLocalStorage = @"cellLocalStorage";
    
    UITableViewCell* cell = nil;
    if (indexPath.row < self.kwmlDevices.count) {
        KWMLDeviceInfo* di = [self.kwmlDevices objectAtIndex:indexPath.row];
    
        DeviceTableViewCell* dcell = [self.tableView dequeueReusableCellWithIdentifier:cellDevice];

        [dcell update:di];
        cell = dcell;
    } else if (indexPath.row < (self.kwmlDevices.count + self.localStorages.count)) {
        
    } else {
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KWMLDeviceInfo* di = [self.kwmlDevices objectAtIndex:indexPath.row];

    FileSystemViewController* fsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FileSystemViewController"];
    
    [fsvc setRootPath:@"/" ofFileSystem:[WebDavFileSystem fileSystemWithUrl:di.url userName:@"" andPassword:@""]];
    
    [self.navigationController pushViewController:fsvc animated:YES];
}


@end
