//
//  WebDavCheckRequest.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavCheckRequest.h"
#import "WebDavClient.h"

#import "LEOWebDAV/LEOWebDAVRequest.h"
#import "LEOWebDAV/LEOWebDAVPropertyRequest.h"


@interface WebDavCheckRequest ()


@property (strong, nonatomic) void(^seccussBlock)(BOOL);
@property (strong, nonatomic) void(^failBlock)(int, NSString*);


@end



@implementation WebDavCheckRequest


- (id)initWithRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock fromClient:(WebDavClient*)client {
    self = [super initWithRequest:request fromClient:client];
    if (self != nil) {
        self.seccussBlock = seccussBlock;
        self.failBlock = failBlock;
    }
    return self;
}


#pragma mark - LEOWebDAVRequestDelegate

- (void)request:(LEOWebDAVRequest *)request didFailWithError:(NSError *)error {
    self.seccussBlock(NO);
}

- (void)request:(LEOWebDAVRequest *)request didSucceedWithResult:(id)result {
    self.seccussBlock(YES);
}


@end
