//
//  InMemmoryCoreDataManager.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "InMemmoryCoreDataManager.h"
#import <CoreData/CoreData.h>


@interface InMemmoryCoreDataManager ()


@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


@end


@implementation InMemmoryCoreDataManager


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;


+ (InMemmoryCoreDataManager*)sharedManager {
    
    static InMemmoryCoreDataManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[InMemmoryCoreDataManager alloc] init];
    });
    
    return manager;
}


#pragma mark - public methods

- (FileSystemItem*)createFileSystemItem {
    return [NSEntityDescription insertNewObjectForEntityForName:@"FileSystemItem" inManagedObjectContext:self.managedObjectContext];
}

- (FileSystemItem*)fileSystemItemByRootPath:(NSString*)rootPath andName:(NSString*)name {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description = [NSEntityDescription entityForName:@"FileSystemItem" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSString* predicateString = [NSString stringWithFormat:@"rootPath == '%@' AND name = '%@'", rootPath, name];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
    
    [request setPredicate:predicate];
    
    return [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

- (NSArray*)fileSystemItemsByRootPath:(NSString*)rootPath {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description = [NSEntityDescription entityForName:@"FileSystemItem" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSString* predicateString = [NSString stringWithFormat:@"rootPath == '%@'", rootPath];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
    
    [request setPredicate:predicate];
    
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}


- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedContext = self.managedObjectContext;
    if (managedContext != nil) {
        if ([managedContext hasChanges] && ![managedContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

- (NSManagedObjectContext*)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSError* error = nil;

    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CustomKMLPlayer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


@end
