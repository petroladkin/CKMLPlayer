//
//  WebDavManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 23.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebDavClient.h"


@interface WebDavManager : NSObject


+ (WebDavManager*)sharedManager;

- (WebDavClient*)clientWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password;



@end
