//
//  DeviceManager.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "DeviceManager.h"
#import "CocoaAsyncSocket/AsyncUdpSocket.h"

#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>


@implementation DeviceInfo


+ (id)deviceInfoWithIpAddress:(NSString*)ipAddress andName:(NSString*)name {
    return [[DeviceInfo alloc] initInfoWithIpAddress:ipAddress andName:name];
}

- (id)initInfoWithIpAddress:(NSString*)ipAddress andName:(NSString*)name {
    self = [super init];
    if (self != nil) {
        _ipAddress = ipAddress;
        _name = name;
    }
    return self;
}


@end


@interface DeviceManager ()


@property (strong, nonatomic) AsyncUdpSocket* udpSocket;
@property (strong, nonatomic) NSTimer* updateTimer;
@property (assign, nonatomic) BOOL foundedServer;


@end


@implementation DeviceManager


+ (DeviceManager*)sharedManager {
    static DeviceManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DeviceManager alloc] init];
    });
    
    return manager;
}


- (id)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (void)start {
    self.udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];

    NSError* error = nil;
    [self.udpSocket bindToPort:5190 error:&error];
    if (error != nil) {
        NSLog(@"DeviceManager - Error (bindToPort): %@", error);
        return;
    }
    
    [self.udpSocket enableBroadcast:YES error:&error];
    if (error != nil) {
        NSLog(@"DeviceManager - Error (enableBroadcast): %@", error);
        return;
    }
    
    [self updateTimer:nil];
    self.foundedServer = YES;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)stop {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    [self.udpSocket close];
    self.udpSocket = nil;
}


#pragma mark - actions

- (void)updateTimer:(id)obj {
    if (!self.foundedServer) {
        if (self.delegate != nil) {
            [self.delegate deviceManager:self updateDeviceList:@[]];
        }
    }
    NSString* myIpAddress = [self getIPAddress];

    NSString* bcIpAddress = myIpAddress;
    NSRange ri = [myIpAddress rangeOfString:@"." options:NSBackwardsSearch];
    if (ri.length > 0) {
        bcIpAddress = [NSString stringWithFormat:@"%@.255", [myIpAddress substringToIndex:ri.location]];
    }

    NSString* message = [NSString stringWithFormat:@"wi-drivec=%@", myIpAddress];
    
    [self.udpSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toHost:bcIpAddress port:5190 withTimeout:-1 tag:0];
    self.foundedServer = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.udpSocket receiveWithTimeout:-1 tag:0];
    });
}


#pragma mark - AsyncUdpSocketDelegate

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"DeviceManager - didNotSendDataWithTag: %ld - %@", tag, error);
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray* msgParts = [msg componentsSeparatedByString:@" "];
    
    if (msgParts.count > 1) {
        NSString* deviceIpAddress = @"";
        NSString* deviceName = @"";
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
        }
        self.foundedServer = YES;
        
        if (self.delegate != nil) {
            [self.delegate deviceManager:self updateDeviceList:@[[DeviceInfo deviceInfoWithIpAddress:deviceIpAddress andName:deviceName]]];
        }
    }
    
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"DeviceManager - didNotReceiveDataWithTag: %ld - %@", tag, error);
}



#pragma mark - help methods

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
