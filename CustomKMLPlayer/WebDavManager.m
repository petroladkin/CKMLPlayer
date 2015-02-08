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


@implementation WebDavItem


+ (id)itemWithName:(NSString*)name url:(NSString*)url andIsFolder:(BOOL)isFolder {
    return [[WebDavItem alloc] initWithName:name url:url andIsFolder:isFolder];
}

- (id)initWithName:(NSString*)name url:(NSString*)url andIsFolder:(BOOL)isFolder {
    self = [super init];
    if (self != nil) {
        _name = name;
        _url = url;
        _isFolder = isFolder;
    }
    return self;
}


@end


@interface WebDavManager ()


@property (strong, nonatomic) LEOWebDAVClient* webDavClient;


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

- (void)connect:(NSString*)ipAddress {
    NSString *root = [NSString stringWithFormat:@"http://%@:8080/", ipAddress];
    self.webDavClient = [[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:root] andUserName:@"" andPassword:@""];
}

- (void)disconnect {
    if (self.webDavClient == nil) return;
    [self.webDavClient cancelRequest];
    [self.webDavClient cancelDelegate];
    self.webDavClient = nil;
}

- (void)requestListFiles:(NSString*)request {
    LEOWebDAVPropertyRequest* webDavRequest = [[LEOWebDAVPropertyRequest alloc] initWithPath:request];
    [webDavRequest setDelegate:self];
    [self.webDavClient enqueueRequest:webDavRequest];
}


#pragma mark - LEOWebDAVRequestDelegate

- (void)request:(LEOWebDAVRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"WebDavManager - Error: %@", error);
    if (self.delegate != nil) {
        [self.delegate webDavManager:self request:request.path didFail:error];
    }
}

- (void)request:(LEOWebDAVRequest *)request didSucceedWithResult:(id)result {
//    NSLog(@"WebDavManager - didSucceedWithResult: %@", result);

    NSArray* items = (NSArray*)result;

    BOOL firstItem = YES;
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:items.count - 1];
    for (LEOWebDAVItem* item in items) {
        if (firstItem) {
            firstItem = NO;
            continue;
        }
        
        WebDavItem* wdi = [WebDavItem itemWithName:item.displayName url:item.href andIsFolder:item.type == LEOWebDAVItemTypeCollection];
        [arr addObject:wdi];
    }
    
    if (self.delegate != nil) {
        [self.delegate webDavManager:self request:request.path responce:arr];
    }
}


@end
