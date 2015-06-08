//
//  WebDavManager.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavManager.h"
#import "WebDavClient.h"


@interface WebDavManager ()


@property (strong, nonatomic) NSMutableArray* clients;

- (void)removeClient:(WebDavClient*)client;


@end


@implementation WebDavManager


+ (WebDavManager*)sharedManager {
    static WebDavManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WebDavManager alloc] init];
    });
    
    return manager;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.clients = [NSMutableArray array];
    }
    return self;
}

- (WebDavClient*)clientWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password {
    WebDavClient* client = [[WebDavClient alloc] initWithUrl:url userName:userName andPassword:password];
    [self.clients addObject:client];
    return client;
}

- (void)removeClient:(WebDavClient*)client {
    [self.clients removeObject:client];
}


@end
