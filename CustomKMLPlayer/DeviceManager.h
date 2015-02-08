//
//  DeviceManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DeviceInfo : NSObject


@property (strong, nonatomic, readonly) NSString* ipAddress;
@property (strong, nonatomic, readonly) NSString* name;


+ (id)deviceInfoWithIpAddress:(NSString*)ipAddress andName:(NSString*)name;
- (id)initInfoWithIpAddress:(NSString*)ipAddress andName:(NSString*)name;


@end


@class DeviceManager;


@protocol DeviceManagerDelegate <NSObject>


@required
- (void)deviceManager:(DeviceManager*)deviceManager updateDeviceList:(NSArray*)devices;


@end


@interface DeviceManager : NSObject


@property (weak, nonatomic) id<DeviceManagerDelegate> delegate;


+ (DeviceManager*)sharedManager;

- (void)start;
- (void)stop;


@end
