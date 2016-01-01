//
//  LocalFileSystem.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 08.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "LocalFileSystem.h"
#import "FileSystemItem.h"
#import "FileSystemItem+More.h"
#import "InMemmoryCoreDataManager.h"

#import <CoreData/CoreData.h>


@interface LocalFileSystem ()


@property (strong, nonatomic) NSString* fileSystemRootPath;


@end


@implementation LocalFileSystem


+ (LocalFileSystem*)fileSystemWithRootPath:(NSString*)rootPath {
    return [[LocalFileSystem alloc] initWithRootPath:rootPath];
}


- (id)initWithRootPath:(NSString*)rootPath {
    self = [super init];
    if (self != nil) {
        self.fileSystemRootPath = rootPath;
    }
    return self;
}

- (void)update:(NSString*)rootPath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString* path = [self.fileSystemRootPath stringByAppendingPathComponent:rootPath];
        
        __block NSString* brootPath = rootPath;
        __block NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        __block NSMutableArray* arr = [NSMutableArray array];
        
        for (NSString* file in files) {

            NSString* filePath = [path stringByAppendingPathComponent:file];
            
            NSDictionary* attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:attr];
            [dic setObject:file forKey:@"fileName"];
            
            [arr addObject:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            NSMutableArray* rlarr = [NSMutableArray array];
            
            for (NSDictionary* dic in arr) {
                NSString* fileName = [dic objectForKey:@"fileName"];
                
                FileSystemItem* item = [[InMemmoryCoreDataManager sharedManager] fileSystemItemByRootPath:brootPath andName:fileName];
                if (item == nil) {
                    item = [[InMemmoryCoreDataManager sharedManager] createFileSystemItem];
                }
                
                item.rootPath = brootPath;
                item.isFolder = [[dic objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory];

                [item setName:fileName isFolder:item.isFolder];
                
                item.url = [path stringByAppendingPathComponent:fileName];
                item.createTime = [dic objectForKey:NSFileCreationDate];
                item.modifyTime = [dic objectForKey:NSFileModificationDate];
                item.llFileSize = [((NSNumber*)[dic objectForKey:NSFileSize]) integerValue];

                [rlarr addObject:item];
            }
            
            [[InMemmoryCoreDataManager sharedManager] saveContext];
            
            NSMutableSet* llset = [NSMutableSet setWithArray:[[InMemmoryCoreDataManager sharedManager] fileSystemItemsByRootPath:brootPath]];
            [llset minusSet:[NSSet setWithArray:rlarr]];
            
            for (FileSystemItem* item in llset) {
                [[InMemmoryCoreDataManager sharedManager].managedObjectContext deleteObject:item];
            }
            
            [[InMemmoryCoreDataManager sharedManager] saveContext];
        });
    });
}


@end
