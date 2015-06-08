//
//  WebDavCheckRequest.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebDavRequest.h"


@interface WebDavCheckRequest : WebDavRequest


- (id)initWithRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock fromClient:(WebDavClient*)client;


@end
