//
//  LocalStorageManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 08.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocalStorageInfo : NSObject


@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* info;
@property (strong, nonatomic, readonly) NSString* url;


@end


@interface LocalStorageManager : NSObject


+ (LocalStorageManager*)sharedManager;


@end
