//
//  WebDavListRequest.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavListRequest.h"
#import "WebDavItem.h"

#import "LEOWebDAV/LEOWebDAVItem.h"


@interface WebDavListRequest ()


@property (strong, nonatomic) void(^seccussBlock)(NSArray*);
@property (strong, nonatomic) void(^failBlock)(int, NSString*);


@end


@implementation WebDavListRequest


- (id)initWithRequest:(NSString*)request seccuss:(void(^)(NSArray*))seccussBlock fail:(void(^)(int, NSString*))failBlock fromClient:(WebDavClient*)client {
    self = [super initWithRequest:request fromClient:client];
    if (self != nil) {
        self.seccussBlock = seccussBlock;
        self.failBlock = failBlock;
    }
    return self;
}


#pragma mark - LEOWebDAVRequestDelegate

- (void)request:(LEOWebDAVRequest *)request didFailWithError:(NSError *)error {
    self.seccussBlock(@[]);
}

- (void)request:(LEOWebDAVRequest *)request didSucceedWithResult:(id)result {
    NSArray* items = (NSArray*)result;

    NSMutableArray* arr = [NSMutableArray array];

    BOOL firstItem = YES;
    for (LEOWebDAVItem* item in items) {
        if (firstItem) {
            firstItem = NO;
            continue;
        }
        
        WebDavItem* wditem = [[WebDavItem alloc] initWithName:item.displayName url:item.href isFolder:(item.type == LEOWebDAVItemTypeCollection) createDate:[NSDate date] modifyDate:[NSDate date] contentLength:item.contentLength];
        
        [arr addObject:wditem];
    }

    self.seccussBlock(arr);
}


@end

