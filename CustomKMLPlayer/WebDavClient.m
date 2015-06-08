//
//  WebDavClient.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavClient.h"
#import "WebDavManager.h"
#import "WebDavCheckRequest.h"
#import "WebDavListRequest.h"

#import "LEOWebDAV/LEOWebDAVClient.h"
#import "LEOWebDAV/LEOWebDAVRequest.h"


@interface WebDavCheckRequest (InitRun)


- (void)run;


@end


@interface WebDavManager (RemoveClient)


- (void)removeClient:(WebDavClient*)client;


@end


@interface WebDavClient ()


@property (strong, nonatomic) LEOWebDAVClient* webDavClient;

@property (strong, nonatomic) NSMutableArray* requests;


- (id)initWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password;

- (void)runRequest:(LEOWebDAVRequest*)request;
- (void)removeRequest:(id)request;


@end


@implementation WebDavClient


- (id)initWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password {
    self = [super init];
    if (self != nil) {
        self.requests = [NSMutableArray array];
        self.webDavClient = [[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:url] andUserName:userName andPassword:password];
    }
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)close {
    if (self.webDavClient == nil) return;
    [self.webDavClient cancelRequest];
    [self.webDavClient cancelDelegate];
    self.webDavClient = nil;
    [[WebDavManager sharedManager] removeClient:self];
}

- (void)checkRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock {
    WebDavCheckRequest* wdcr = [[WebDavCheckRequest alloc] initWithRequest:request seccuss:seccussBlock fail:failBlock fromClient:self];
    [wdcr run];
    [self.requests addObject:wdcr];
}

- (void)listRequest:(NSString*)request seccuss:(void(^)(NSArray*))seccussBlock fail:(void(^)(int, NSString*))failBlock {
    WebDavListRequest* wdlr = [[WebDavListRequest alloc] initWithRequest:request seccuss:seccussBlock fail:failBlock fromClient:self];
    [wdlr run];
    [self.requests addObject:wdlr];
}

- (void)runRequest:(LEOWebDAVRequest*)request {
    [self.webDavClient enqueueRequest:request];
}

- (void)removeRequest:(id)request {
    [self.requests removeObject:request];
}


@end
