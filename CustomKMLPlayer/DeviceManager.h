//
//  DeviceManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, DeviceInfoPortStatus) {
    DeviceInfoPortStatusUnknown,
    DeviceInfoPortStatusConnected,
    DeviceInfoPortStatusDisconnected
};



@interface DeviceInfo : NSObject


@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* info;
@property (strong, nonatomic, readonly) NSString* ipAddress;
@property (assign, nonatomic, readonly) DeviceInfoPortStatus sdCardStatus;
@property (assign, nonatomic, readonly) DeviceInfoPortStatus usbDeviceStatus;


@end


static NSString *const DeviceManagerWillUpdateDeviceList = @"DeviceManagerWillUpdateDeviceList";
static NSString *const DeviceManagerDidUpdateDeviceList = @"DeviceManagerDidUpdateDeviceList";
static NSString *const DeviceManagerFailUpdateDeviceList = @"DeviceManagerFailUpdateDeviceList";
static NSString *const DeviceManagerTimeoutUpdateDeviceList = @"DeviceManagerTimeoutUpdateDeviceList";

static NSString *const DeviceManagerDidUpdateDeviceInfo = @"DeviceManagerDidUpdateDeviceInfo";


@interface DeviceManager : NSObject


+ (DeviceManager*)sharedManager;


@property (assign, nonatomic, readonly) NSArray* devices;


- (void)updateDeviceList;

- (void)startKeapAliveTimer;
- (void)stopKeapAliveTimer;


@end
