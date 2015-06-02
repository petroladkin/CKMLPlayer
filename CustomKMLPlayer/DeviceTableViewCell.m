//
//  DeviceTableViewCell.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 15.05.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "DeviceTableViewCell.h"


@interface DeviceTableViewCell ()


@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceIpLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *usbStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *sdStausLabel;


@end


@implementation DeviceTableViewCell


- (void)awakeFromNib {
}

- (void)update:(DeviceInfo*)deviceInfo {
    self.deviceNameLabel.text = deviceInfo.name;
    self.deviceIpLabel.text = deviceInfo.ipAddress;
    self.deviceInfoLabel.text = deviceInfo.info;
    [self setStatus:deviceInfo.sdCardStatus toLabel:self.sdStausLabel];
    [self setStatus:deviceInfo.usbDeviceStatus toLabel:self.usbStatusLabel];
}


#pragma mark - help methods

- (void)setStatus:(DeviceInfoPortStatus)status toLabel:(UILabel*)label {
    switch (status) {
        case DeviceInfoPortStatusUnknown:
            label.text = @"unknown";
            label.textColor = [UIColor grayColor];
            break;
        case DeviceInfoPortStatusConnected:
            label.text = @"connected";
            label.textColor = [UIColor greenColor];
            break;
        case DeviceInfoPortStatusDisconnected:
            label.text = @"disconnected";
            label.textColor = [UIColor redColor];
            break;
    }
}


@end
