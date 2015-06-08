//
//  WebDavRequest.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LEOWebDAV/LEOWebDAVRequest.h"


@class WebDavClient;


@interface WebDavRequest : NSObject <LEOWebDAVRequestDelegate>


- (id)initWithRequest:(NSString*)request fromClient:(WebDavClient*)client;
- (void)run;


@end
