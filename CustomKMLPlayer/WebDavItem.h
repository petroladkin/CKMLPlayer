//
//  WebDavItem.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebDavItem : NSObject


@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* url;
@property (assign, nonatomic, readonly) BOOL isFolder;
@property (strong, nonatomic, readonly) NSDate* createDate;
@property (strong, nonatomic, readonly) NSDate* modifyDate;
@property (assign, nonatomic, readonly) long long contentLength;


- (id)initWithName:(NSString*)name url:(NSString*)url isFolder:(BOOL)isFolder createDate:(NSDate*)createDate modifyDate:(NSDate*)modifyDate contentLength:(long long) contentLength;


@end
