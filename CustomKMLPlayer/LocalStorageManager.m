//
//  LocalStorageManager.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 08.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "LocalStorageManager.h"


@implementation LocalStorageManager


+ (LocalStorageManager*)sharedManager {
    static LocalStorageManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocalStorageManager alloc] init];
    });
    
    return manager;
}


- (id)init {
    self = [super init];
    if (self != nil) {
//        self.realDevices = [NSMutableArray array];
//        self.devicesByKey = [NSMutableDictionary dictionary];
//        //        self.queue = dispatch_queue_create("ua.com.pela.ckwmlplayer.asqueue", DISPATCH_QUEUE_CONCURRENT);
//        [self start];
    }
    return self;
}


@end
