//
//  TableItem.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, ETableItemType) {
    ETableItemTypeUnknown,
    ETableItemTypeDevice,
    ETableItemTypeLocalStorage,
    ETableItemTypeFolder,
    ETableItemTypeFile
};


@interface TableItem : NSObject


@property (assign, nonatomic, readonly) ETableItemType type;
@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* info;


+ (TableItem*)itemWithType:(ETableItemType)type name:(NSString*)name andInfo:(NSString*)info;

- (id)initWithType:(ETableItemType)type name:(NSString*)name andInfo:(NSString*)info;


@end
