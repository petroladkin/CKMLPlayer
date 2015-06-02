//
//  WebDavManager.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavManager.h"
#import "LEOWebDAV/LEOWebDAVClient.h"
#import "LEOWebDAV/LEOWebDAVPropertyRequest.h"
#import "LEOWebDAV/LEOWebDAVItem.h"


//- (void)request:(LEOWebDAVRequest *)request didFailWithError:(NSError *)error {
//    NSLog(@"WebDavManager - didFailWithError: %@", request.path);
//}
//
//- (void)request:(LEOWebDAVRequest *)request didSucceedWithResult:(id)result {
//    NSLog(@"WebDavManager - didSucceedWithResult: %@", request.path);
//    
//    //    NSArray* items = (NSArray*)result;
//    //
//    //    BOOL firstItem = YES;
//    //    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:items.count - 1];
//    //    for (LEOWebDAVItem* item in items) {
//    //        if (firstItem) {
//    //            firstItem = NO;
//    //            continue;
//    //        }
//    //
//    //        //        WebDavItem* wdi = [WebDavItem itemWithName:item.displayName url:item.href andIsFolder:item.type == LEOWebDAVItemTypeCollection];
//    //        //        [arr addObject:wdi];
//    //    }
//    //
//    //    if (self.delegate != nil) {
//    //        [self.delegate webDavManager:self request:request.path responce:arr];
//    //    }
//}


@class WebDavClient;


#pragma mark - @interface WebDavCheckRequest

@interface WebDavCheckRequest : NSObject <LEOWebDAVRequestDelegate>


@property (weak, nonatomic) WebDavClient* client;
@property (strong, nonatomic) LEOWebDAVPropertyRequest* webDavRequest;
@property (strong, nonatomic) void(^seccussBlock)(BOOL);
@property (strong, nonatomic) void(^failBlock)(int, NSString*);


- (id)initWithRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock fromClient:(WebDavClient*)client;
- (void)run;


@end


#pragma mark - @interface WebDavClient ()

@interface WebDavClient ()


@property (strong, nonatomic) LEOWebDAVClient* webDavClient;

@property (strong, nonatomic) NSMutableArray* requests;


- (id)initWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password;

- (void)runRequest:(LEOWebDAVRequest*)request;
- (void)removeRequest:(id)request;


@end


#pragma mark - @interface WebDavManager ()

@interface WebDavManager ()


@property (strong, nonatomic) LEOWebDAVClient* webDavClient;

@property (strong, nonatomic) NSMutableArray* clients;


- (void)removeClient:(WebDavClient*)client;


@end


#pragma mark - @implementation WebDavCheckRequest

@implementation WebDavCheckRequest


- (id)initWithRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock fromClient:(WebDavClient*)client {
    self = [super init];
    if (self != nil) {
        self.client = client;
        self.webDavRequest = [[LEOWebDAVPropertyRequest alloc] initWithPath:request];
        [self.webDavRequest setDelegate:self];
        self.seccussBlock = seccussBlock;
        self.failBlock = failBlock;
    }
    return self;
}

- (void)run {
    [self.client runRequest:self.webDavRequest];
}


#pragma mark - LEOWebDAVRequestDelegate

- (void)request:(LEOWebDAVRequest *)request didFailWithError:(NSError *)error {
    self.seccussBlock(NO);
}

- (void)request:(LEOWebDAVRequest *)request didSucceedWithResult:(id)result {
    self.seccussBlock(YES);
}


@end


#pragma mark - @implementation WebDavClient

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

- (void)runRequest:(LEOWebDAVRequest*)request {
    [self.webDavClient enqueueRequest:request];
}

- (void)removeRequest:(id)request {
    [self.requests removeObject:request];
}


@end


#pragma mark - @implementation WebDavManager

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
