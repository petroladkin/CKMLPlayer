//
//  WebDavItem.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavItem.h"


@implementation WebDavItem


- (id)initWithName:(NSString*)name url:(NSString*)url isFolder:(BOOL)isFolder createDate:(NSDate*)createDate modifyDate:(NSDate*)modifyDate contentLength:(long long) contentLength {
    self = [super init];
    if (self != nil) {
        _name = name;
        _url = url;
        _isFolder = isFolder;
        _createDate = createDate;
        _modifyDate = modifyDate;
        _contentLength = contentLength;
    }
    return self;
}


@end
