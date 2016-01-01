//
//  LocalFileSystem.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 08.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystem.h"


@interface LocalFileSystem : FileSystem


+ (LocalFileSystem*)fileSystemWithRootPath:(NSString*)rootPath;


@end
