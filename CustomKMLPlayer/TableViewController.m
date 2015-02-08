//
//  TableViewController.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "TableViewController.h"
#import "TableItem.h"
#import "GroupTableViewCell.h"
#import "ItemTableViewCell.h"
#import "PlayerViewController.h"


@interface TableViewController ()


@property (strong, nonatomic) NSArray* content;

@property (strong, nonatomic) NSString* webDavIpAddress;


@end


@implementation TableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.notRootContaroller) {
        self.navigationItem.title = @"KML Player";
    }
    
    self.content = [NSArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.notRootContaroller) {
        [[WebDavManager sharedManager] disconnect];
        
        [DeviceManager sharedManager].delegate = self;
        [[DeviceManager sharedManager] start];
    } else {
        [WebDavManager sharedManager].delegate = self;
    }

    [self updateContent:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (!self.notRootContaroller) {
        [[DeviceManager sharedManager] stop];
        [[WebDavManager sharedManager] connect:self.webDavIpAddress];
    } else {
        
    }
}


#pragma mark - help methods

- (void)updateContent:(NSArray*)content {
    if (!self.notRootContaroller) {
        if (content != nil) {
            self.content = [NSArray arrayWithArray:content];
        }
    } else {
        if (content == nil) {
            [[WebDavManager sharedManager] requestListFiles:self.webDavPath];
        } else {
            self.content = [NSArray arrayWithArray:content];
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellGroup = @"cellGroup";
    NSString* cellItem = @"cellItem";
    
    if (!self.notRootContaroller) {
        GroupTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellGroup forIndexPath:indexPath];
     
        TableItem* ti = [self.content objectAtIndex:indexPath.row];
        
        [cell update:ti];
        
        return cell;
    } else {
        UITableViewCell* cell = nil;
        
        TableItem* ti = [self.content objectAtIndex:indexPath.row];

        if (ti.type == ETableItemTypeFolder) {
            GroupTableViewCell* gcell = [tableView dequeueReusableCellWithIdentifier:cellGroup forIndexPath:indexPath];
            [gcell update:ti];
            cell = gcell;
        } else {
            ItemTableViewCell* icell = [tableView dequeueReusableCellWithIdentifier:cellItem forIndexPath:indexPath];
            [icell update:ti];
            cell = icell;
        }
        
        return cell;
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.notRootContaroller) {
        TableItem* ti = [self.content objectAtIndex:indexPath.row];

        self.webDavIpAddress = ti.info;
        
        TableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
        
        tvc.notRootContaroller = YES;
        tvc.webDavPath = @"/";
        tvc.navigationItem.title = ti.name;
        
        [self.navigationController pushViewController:tvc animated:YES];
    } else {
        TableItem* ti = [self.content objectAtIndex:indexPath.row];

        if (ti.type == ETableItemTypeFolder) {
            TableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
            
            tvc.notRootContaroller = YES;
            tvc.webDavPath = [NSString stringWithFormat:@"/%@/%@/", self.webDavPath, ti.name];
            tvc.navigationItem.title = ti.name;
            
            [self.navigationController pushViewController:tvc animated:YES];
        } else {
            PlayerViewController* pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
            
            NSMutableArray* arr = [NSMutableArray array];
            
            for (TableItem* item in self.content) {
                if (item.type == ETableItemTypeFile && ([[item.info pathExtension] isEqualToString:@"mp4"] || [[item.info pathExtension] isEqualToString:@"m4v"])) {
                    WebDavItem* wdi = [WebDavItem itemWithName:item.name url:item.info andIsFolder:NO];
                    [arr addObject:wdi];
                }
            }
            
            pvc.files = arr;
            pvc.currentFileIndex = indexPath.row;

            [self.navigationController pushViewController:pvc animated:YES];
        }
    }
}


#pragma mark - DeviceManagerDelegate

- (void)deviceManager:(DeviceManager*)deviceManager updateDeviceList:(NSArray*)devices {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:devices.count];
    for (DeviceInfo* di in devices) {
        TableItem* ti = [TableItem itemWithType:ETableItemTypeDevice name:di.name andInfo:di.ipAddress];
        [arr addObject:ti];
    }
    [self updateContent:arr];
}


#pragma mark - WebDavManagerDelegate

- (void)webDavManager:(WebDavManager*)webDavManager request:(NSString*)request responce:(NSArray*)responce {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:responce.count];
    for (WebDavItem* wdi in responce) {
        TableItem* ti = [TableItem itemWithType:(wdi.isFolder ? ETableItemTypeFolder : ETableItemTypeFile) name:wdi.name andInfo:wdi.url];
        [arr addObject:ti];
    }
    [self updateContent:arr];
}

- (void)webDavManager:(WebDavManager*)webDavManager request:(NSString*)request didFail:(NSError*)error {
}


@end
