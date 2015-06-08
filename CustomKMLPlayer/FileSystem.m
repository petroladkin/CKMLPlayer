//
//  FileSystem.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystem.h"
#import <CoreData/CoreData.h>
#import "InMemmoryCoreDataManager.h"
#import "FileSystemItem.h"
#import "FileSystemItem+More.h"


@implementation FileSystem


- (NSFetchedResultsController*)fileSystemFetchedResultsControllerByRootPath:(NSString*)rootPath filter:(NSString*)filter type:(FileSystemItemFilterType)type andGroupFolder:(BOOL)isGroupFolders sortBy:(FileSystemFileSort)sort {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description = [NSEntityDescription entityForName:@"FileSystemItem" inManagedObjectContext:[InMemmoryCoreDataManager sharedManager].managedObjectContext];
    [request setEntity:description];
    
    NSString* predicateTypeString = @"";
    switch (type) {
        case FileSystemItemFilterTypeAll:
            break;
        case FileSystemItemFilterTypeVideo:
            predicateTypeString = [NSString stringWithFormat:@"AND fileType == %lu", (unsigned long)FileSystemItemTypeVideo];
            break;
        case FileSystemItemFilterTypeImages:
            predicateTypeString = [NSString stringWithFormat:@"AND fileType == %lu", (unsigned long)FileSystemItemTypeImage];
            break;
        case FileSystemItemFilterTypeMusic:
            predicateTypeString = [NSString stringWithFormat:@"AND fileType == %lu", (unsigned long)FileSystemItemTypeMusic];
            break;
        case FileSystemItemFilterTypeOthers:
            predicateTypeString = [NSString stringWithFormat:@"AND fileType == %lu", (unsigned long)FileSystemItemTypeUnknown];
            break;
    }
    
    NSString* predicateFilterString = @"";
    if (filter != nil && filter.length > 0) {
        predicateFilterString = [NSString stringWithFormat:@" AND name BEGINSWITH[cd] '%@'", filter];
    }
    
    NSString* predicateString = [NSString stringWithFormat:@"rootPath == '%@'%@%@", rootPath, predicateTypeString, predicateFilterString];
    
    if (predicateString.length > 0) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }

    NSArray* sortDescriptors = nil;
    switch (sort) {
        case FileSystemFileSortNameAsc:
            if (isGroupFolders) {
                sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"folder" ascending:NO], [[NSSortDescriptor alloc] initWithKey:@"lowercaseName" ascending:YES]];
            } else {
                sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"lowercaseName" ascending:YES]];
            }
            break;
        case FileSystemFileSortNameDesc:
            if (isGroupFolders) {
                sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"folder" ascending:YES], [[NSSortDescriptor alloc] initWithKey:@"lowercaseName" ascending:NO]];
            } else {
                sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"lowercaseName" ascending:NO]];
            }
            break;
        case FileSystemFileSortDateAsc:
            sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"modifyTime" ascending:YES]];
            break;
        case FileSystemFileSortDateDesc:
            sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"modifyTime" ascending:NO]];
            break;
        case FileSystemFileSortSizeAsc:
            sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"fileSize" ascending:YES]];
            break;
        case FileSystemFileSortSizeDesc:
            sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"fileSize" ascending:NO]];
            break;
    }
    if (sortDescriptors != nil) {
//        NSArray *sortDescriptors = @[sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
    }

    NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[InMemmoryCoreDataManager sharedManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return fetchedResultsController;
}

- (void)update:(NSString*)rootPath {
}


@end
