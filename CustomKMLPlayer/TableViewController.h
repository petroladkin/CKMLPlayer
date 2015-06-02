//
//  TableViewController.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DeviceManager.h"
//#import "WebDavManager.h"


@interface TableViewController : UITableViewController <DeviceManagerDelegate, WebDavManagerDelegate>


@property (assign, nonatomic) BOOL notRootContaroller;

@property (strong, nonatomic) NSString* webDavPath;


@end
