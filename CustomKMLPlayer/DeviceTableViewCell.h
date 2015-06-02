//
//  DeviceTableViewCell.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 15.05.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"


@interface DeviceTableViewCell : UITableViewCell


- (void)update:(DeviceInfo*)deviceInfo;


@end