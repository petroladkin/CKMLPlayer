//
//  DevicesViewController.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 15.05.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "SourcesViewController.h"
#import "FileSystemViewController.h"

#import "KWMLDeviceTableViewCell.h"
#import "LocalStorageTableViewCell.h"

#import "KWMLDeviceManager.h"
#import "LocalStorageManager.h"

#import "WebDavFileSystem.h"
#import "LocalFileSystem.h"

//#import "InMemmoryCoreDataManager.h"


@interface SourcesViewController () <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIActivityIndicatorView* busyIndicator;
@property (strong, nonatomic) UIRefreshControl* tableRefreshControl;

@property (weak, nonatomic) KWMLDeviceInfo* kwmlDevice;
@property (weak, nonatomic) LocalStorageInfo* localStorage;


@end


@implementation SourcesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.tableRefreshControl];
    [self.tableRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.busyIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.busyIndicator];
    
    self.kwmlDevice = nil;
    self.localStorage = nil;
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(deviceManagerWillUpdateDeviceList:) name:DeviceManagerWillUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerDidUpdateDeviceList:) name:DeviceManagerDidUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerFailUpdateDeviceList:) name:DeviceManagerFailUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerTimeoutUpdateDeviceList:) name:DeviceManagerTimeoutUpdateDeviceList object:nil];
    [nc addObserver:self selector:@selector(deviceManagerDidUpdateDeviceInfo:) name:DeviceManagerDidUpdateDeviceInfo object:nil];
    
//    [[KWMLDeviceManager sharedManager] updateDevice];
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
    
    self.kwmlDevice = [KWMLDeviceManager sharedManager].device;
    
    [self.tableView reloadData];
}

- (void)deviceManagerFailUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];

    self.kwmlDevice = nil;
    
    [self.tableView reloadData];
}

- (void)deviceManagerTimeoutUpdateDeviceList:(NSNotification*)notification {
    [self.busyIndicator stopAnimating];
    [self.tableRefreshControl endRefreshing];
    
    self.kwmlDevice = nil;
    
    [self.tableView reloadData];
}

- (void)deviceManagerDidUpdateDeviceInfo:(NSNotification*)notification {
    self.kwmlDevice = [KWMLDeviceManager sharedManager].device;
    [self.tableView reloadData];
}


#pragma mark - events

- (void)refreshTable {
    [[KWMLDeviceManager sharedManager] updateDevice];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 /*devices*/ + 1 /*local storage*/;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.kwmlDevice != nil ? 1 : 0;
    } else if (section == 1) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellDevice = @"cellKWMLDevice";
    static NSString* cellLocalStorage = @"cellLocalStorage";
    
    UITableViewCell* cell = nil;
    if (indexPath.section == 0) {
        KWMLDeviceTableViewCell* dcell = [self.tableView dequeueReusableCellWithIdentifier:cellDevice];

        [dcell update:self.kwmlDevice];
        cell = dcell;
    } else if (indexPath.section == 1) {
        LocalStorageTableViewCell* lscell = [self.tableView dequeueReusableCellWithIdentifier:cellLocalStorage];
        
        cell = lscell;
    } else {
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileSystemViewController* fsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FileSystemViewController"];
    if (indexPath.section == 0) {
        [fsvc setRootPath:@"/" ofFileSystem:[WebDavFileSystem fileSystemWithUrl:self.kwmlDevice.url userName:@"" andPassword:@""]];
    } else if (indexPath.section == 1) {
        NSURL* rootPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

        [fsvc setRootPath:@"/" ofFileSystem:[LocalFileSystem fileSystemWithRootPath:rootPath.path]];
    } else {
    }
    [self.navigationController pushViewController:fsvc animated:YES];
}


@end
