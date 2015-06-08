//
//  WebDavRequest.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavRequest.h"
#import "WebDavClient.h"

#import "LEOWebDAV/LEOWebDAVPropertyRequest.h"


@interface WebDavClient (RunRequest)


- (void)runRequest:(LEOWebDAVRequest*)request;


@end


@interface WebDavRequest ()


@property (weak, nonatomic) WebDavClient* client;
@property (strong, nonatomic) LEOWebDAVPropertyRequest* webDavRequest;


@end


@implementation WebDavRequest


- (id)initWithRequest:(NSString*)request fromClient:(WebDavClient*)client {
    self = [super init];
    if (self != nil) {
        self.client = client;
        self.webDavRequest = [[LEOWebDAVPropertyRequest alloc] initWithPath:request];
        [self.webDavRequest setDelegate:self];
    }
    return self;
}

- (void)run {
    [self.client runRequest:self.webDavRequest];
}


#pragma mark - LEOWebDAVRequestDelegate

- (void)request:(LEOWebDAVRequest *)request didFailWithError:(NSError *)error {
}

- (void)request:(LEOWebDAVRequest *)request didSucceedWithResult:(id)result {
}


@end
