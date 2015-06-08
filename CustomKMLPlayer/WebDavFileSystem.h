//
//  WebDavFileSystem.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystem.h"


@interface WebDavFileSystem : FileSystem


+ (WebDavFileSystem*)fileSystemWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password;


@end
