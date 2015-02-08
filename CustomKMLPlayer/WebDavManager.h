//
//  WebDavManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEOWebDAVRequest.h"


@interface WebDavItem : NSObject


@property (assign, nonatomic, readonly) BOOL isFolder;
@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* url;


+ (id)itemWithName:(NSString*)name url:(NSString*)url andIsFolder:(BOOL)isFolder;

- (id)initWithName:(NSString*)name url:(NSString*)url andIsFolder:(BOOL)isFolder;


@end


@class WebDavManager;


@protocol WebDavManagerDelegate <NSObject>


@required
- (void)webDavManager:(WebDavManager*)webDavManager request:(NSString*)request responce:(NSArray*)responce;
- (void)webDavManager:(WebDavManager*)webDavManager request:(NSString*)request didFail:(NSError*)error;


@end


@interface WebDavManager : NSObject <LEOWebDAVRequestDelegate>


@property (weak, nonatomic) id<WebDavManagerDelegate> delegate;


+ (WebDavManager*)sharedManager;


- (void)connect:(NSString*)ipAddress;
- (void)disconnect;

- (void)requestListFiles:(NSString*)request;


@end
