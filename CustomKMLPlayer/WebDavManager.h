//
//  WebDavManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEOWebDAVRequest.h"


@interface WebDavClient : NSObject


- (void)close;

- (void)checkRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock;
//- (void)requestListFiles:(NSString*)request;


@end


@interface WebDavManager : NSObject


+ (WebDavManager*)sharedManager;

- (WebDavClient*)clientWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password;


@end
