//
//  FileSystem.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NSFetchedResultsController;
@class NSFetchRequest;


typedef NS_ENUM(NSUInteger, FileSystemItemFilterType) {
    FileSystemItemFilterTypeAll,
    FileSystemItemFilterTypeVideo,
    FileSystemItemFilterTypeImages,
    FileSystemItemFilterTypeMusic,
    FileSystemItemFilterTypeOthers
};


typedef NS_ENUM(NSUInteger, FileSystemFileSort) {
    FileSystemFileSortNameAsc,
    FileSystemFileSortNameDesc,
    FileSystemFileSortDateAsc,
    FileSystemFileSortDateDesc,
    FileSystemFileSortSizeAsc,
    FileSystemFileSortSizeDesc,
};


@interface FileSystem : NSObject


- (NSFetchedResultsController*)fileSystemFetchedResultsControllerByRootPath:(NSString*)rootPath filter:(NSString*)filter type:(FileSystemItemFilterType)type andGroupFolder:(BOOL)isGroupFolders sortBy:(FileSystemFileSort)sort;


- (void)update:(NSString*)rootPath;


@end
