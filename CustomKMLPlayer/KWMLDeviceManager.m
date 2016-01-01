//
//  DeviceManager.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "KWMLDeviceManager.h"
#import "CocoaAsyncSocket/AsyncUdpSocket.h"
#import "WebDavManager.h"

#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>


@interface KWMLDeviceInfo ()


+ (id)deviceInfoWithIpAddress:(NSString*)ipAddress name:(NSString*)name andInfo:(NSString*)info;

- (id)initInfoWithIpAddress:(NSString*)ipAddress name:(NSString*)name andInfo:(NSString*)info;
- (void)setName:(NSString*)name andInfo:(NSString*)info;
- (void)setSdCardStatus:(DeviceInfoPortStatus)sdCardStatus;
- (void)setUsbDevice:(DeviceInfoPortStatus)usbDeviceStatus;


@end


@implementation KWMLDeviceInfo


+ (id)deviceInfoWithIpAddress:(NSString*)ipAddress name:(NSString*)name andInfo:(NSString*)info {
    return [[KWMLDeviceInfo alloc] initInfoWithIpAddress:ipAddress name:name andInfo:info];
}

- (id)initInfoWithIpAddress:(NSString*)ipAddress name:(NSString*)name andInfo:(NSString*)info {
    self = [super init];
    if (self != nil) {
        _name = name;
        _info = info;
        _ipAddress = ipAddress;
        _url = [NSString stringWithFormat:@"http://%@:8080/", ipAddress];
        _sdCardStatus = DeviceInfoPortStatusUnknown;
        _usbDeviceStatus = DeviceInfoPortStatusUnknown;
    }
    return self;
}

- (void)setName:(NSString*)name andInfo:(NSString*)info {
    _name = name;
    _info = info;
}

- (void)setSdCardStatus:(DeviceInfoPortStatus)sdCardStatus {
    _sdCardStatus = sdCardStatus;
}

- (void)setUsbDevice:(DeviceInfoPortStatus)usbDeviceStatus {
    _usbDeviceStatus = usbDeviceStatus;
}


@end


const static int MaxNotReceiveCounter = 3;


@interface KWMLDeviceManager ()


@property (strong, nonatomic) AsyncUdpSocket* udpSocket;
@property (strong, nonatomic) NSTimer* updateTimer;
@property (strong, nonatomic) NSTimer* receiveTimer;

@property (assign, nonatomic) int notReceiveResponceCouter;
//@property (strong, nonatomic) dispatch_queue_t queue;


@end


@implementation KWMLDeviceManager


+ (KWMLDeviceManager*)sharedManager {
    static KWMLDeviceManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KWMLDeviceManager alloc] init];
    });
    
    return manager;
}


- (id)init {
    self = [super init];
    if (self != nil) {
//        self.queue = dispatch_queue_create("ua.com.pela.ckwmlplayer.asqueue", DISPATCH_QUEUE_CONCURRENT);
        [self start];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)updateDevice {
    [self updateTimer:nil];
}

- (void)startKeapAliveTimer {
}

- (void)stopKeapAliveTimer {
}


#pragma mark - actions

- (void)updateTimer:(id)obj {
    ++self.notReceiveResponceCouter;
    if (self.notReceiveResponceCouter > MaxNotReceiveCounter) {
        _device = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerTimeoutUpdateDeviceList object:@"Timeout to receive device responce"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerWillUpdateDeviceList object:self];
    
    NSString* myIpAddress = [self getIPAddress];

    NSString* bcIpAddress = myIpAddress;
    NSRange ri = [myIpAddress rangeOfString:@"." options:NSBackwardsSearch];
    if (ri.length > 0) {
        bcIpAddress = [NSString stringWithFormat:@"%@.255", [myIpAddress substringToIndex:ri.location]];
    }

    NSString* message = [NSString stringWithFormat:@"wi-drivec=%@", myIpAddress];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
//    dispatch_sync(self.queue, ^(){
        if ([self.udpSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toHost:bcIpAddress port:5190 withTimeout:-1 tag:0]) {
            [self.udpSocket receiveWithTimeout:30 tag:0];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerFailUpdateDeviceList object:@"Failed send data over socket"];
        }
    });
}

- (void)receiveTimer:(id)obj {
    [self.udpSocket receiveWithTimeout:30 tag:0];
}



#pragma mark - AsyncUdpSocketDelegate

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerFailUpdateDeviceList object:@"Failed send data over socket"];
    [self stop];
    [self start];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    NSRange ri = [host rangeOfString:[self getIPAddress]];
    if (ri.length > 0) return NO;
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* msgParts = [msg componentsSeparatedByString:@" "];
    
    if (msgParts.count == 4) {
        self.notReceiveResponceCouter = 0;

        NSString* deviceIpAddress = @"";
        NSString* deviceName = @"";
        NSString* deviceModel = @"";
        NSString* deviceVersion = @"";
        for (NSString* part in msgParts) {
            NSRange ri = [part rangeOfString:@"ssid="];
            if (ri.length > 0) {
                ri.location = @"ssid=".length + 1;
                ri.length = part.length - (ri.location + 1);
                deviceName = [part substringWithRange:ri];
                continue;
            }
            ri = [part rangeOfString:@"wi-drives="];
            if (ri.length > 0) {
                deviceIpAddress = [part substringFromIndex:@"wi-drives=".length];
                continue;
            }
            ri = [part rangeOfString:@"model="];
            if (ri.length > 0) {
                ri.location = @"model=".length + 1;
                ri.length = part.length - (ri.location + 1);
                deviceModel = [part substringWithRange:ri];
                continue;
            }
            ri = [part rangeOfString:@"version="];
            if (ri.length > 0) {
                ri.location = @"version=".length + 1;
                ri.length = part.length - (ri.location + 1);
                deviceVersion = [part substringWithRange:ri];
                continue;
            }
        }
        NSString* info = [NSString stringWithFormat:@"%@ (%@)", deviceModel, deviceVersion];
        
        if (self.device != nil) {
            [self.device setName:deviceName andInfo:info];
        } else {
            _device = [KWMLDeviceInfo deviceInfoWithIpAddress:deviceIpAddress name:deviceName andInfo:info];
        }
        [self getPortStatus:self.device];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerDidUpdateDeviceList object:self];
    }
    
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    [self stop];
    [self start];
}



#pragma mark - help methods

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^(){
//    dispatch_async(self.queue, ^(){
        self.udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];

        NSError* error = nil;
        [self.udpSocket bindToPort:5190 error:&error];
        if (error != nil) {
            return;
        }
        
        [self.udpSocket enableBroadcast:YES error:&error];
        if (error != nil) {
            return;
        }
    });
    
    self.notReceiveResponceCouter = 0;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    self.receiveTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(receiveTimer:) userInfo:nil repeats:YES];
}

- (void)stop {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    [self.receiveTimer invalidate];
    self.receiveTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^(){
//    dispatch_async(self.queue, ^(){
        [self.udpSocket close];
        self.udpSocket = nil;
    });
}

- (void)getPortStatus:(KWMLDeviceInfo*)device {
    __weak KWMLDeviceInfo* wdevice = device;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        WebDavClient* wdc = [[WebDavManager sharedManager] clientWithUrl:device.url userName:@"" andPassword:@""];
        [wdc checkRequest:@"/SD_Card1/" seccuss:^(BOOL exist) {
            [wdevice setSdCardStatus:exist ? DeviceInfoPortStatusConnected : DeviceInfoPortStatusDisconnected];
            [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerDidUpdateDeviceInfo object:wdevice];
        } fail:^(int code, NSString* message) {
            NSLog(@"Fail checkRequest SDCard: (%d) %@", code, message);
        }];
        [wdc checkRequest:@"/USB1/" seccuss:^(BOOL exist) {
            [wdevice setUsbDevice:exist ? DeviceInfoPortStatusConnected : DeviceInfoPortStatusDisconnected];
            [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerDidUpdateDeviceInfo object:wdevice];
        } fail:^(int code, NSString* message) {
            NSLog(@"Fail checkRequest USBDevice: (%d) %@", code, message);
        }];
    });
}

- (NSString*)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // Retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


@end
