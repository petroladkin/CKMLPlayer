//
//  WebDavClient.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebDavClient : NSObject


- (id)initWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password;

- (void)close;

- (void)checkRequest:(NSString*)request seccuss:(void(^)(BOOL))seccussBlock fail:(void(^)(int, NSString*))failBlock;
- (void)listRequest:(NSString*)request seccuss:(void(^)(NSArray*))seccussBlock fail:(void(^)(int, NSString*))failBlock;


@end
