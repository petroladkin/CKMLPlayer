//
//  InMemmoryCoreDataManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NSManagedObjectContext;
@class FileSystemItem;


@interface InMemmoryCoreDataManager : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


+ (InMemmoryCoreDataManager*)sharedManager;

- (FileSystemItem*)createFileSystemItem;
- (FileSystemItem*)fileSystemItemByRootPath:(NSString*)rootPath andName:(NSString*)name;
- (NSArray*)fileSystemItemsByRootPath:(NSString*)rootPath;

- (void)saveContext;


@end
