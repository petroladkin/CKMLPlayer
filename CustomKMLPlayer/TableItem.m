//
//  TableItem.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "TableItem.h"


@implementation TableItem


+ (TableItem*)itemWithType:(ETableItemType)type name:(NSString*)name andInfo:(NSString*)info {
    return [[TableItem alloc] initWithType:type name:name andInfo:info];
}

- (id)initWithType:(ETableItemType)type name:(NSString*)name andInfo:(NSString*)info {
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = name;
        _info = info;
    }
    return self;
}


@end
