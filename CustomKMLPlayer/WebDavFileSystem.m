//
//  WebDavFileSystem.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "WebDavFileSystem.h"
#import "WebDavManager.h"
#import "WebDavItem.h"
#import "FileSystemItem.h"
#import "FileSystemItem+More.h"
#import "InMemmoryCoreDataManager.h"

#import <CoreData/CoreData.h>


@interface WebDavFileSystem ()


@property (strong, nonatomic) NSString* deviceUrl;
@property (strong, nonatomic) NSString* deviceUserName;
@property (strong, nonatomic) NSString* devicePassword;


@end


@implementation WebDavFileSystem


+ (WebDavFileSystem*)fileSystemWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password {
    return [[WebDavFileSystem alloc] initWithUrl:url userName:userName andPassword:password];
}


- (id)initWithUrl:(NSString*)url userName:(NSString*)userName andPassword:(NSString*)password {
    self = [super init];
    if (self != nil) {
        self.deviceUrl = url;
        self.deviceUserName = userName;
        self.devicePassword = password;
    }
    return self;
}

- (void)update:(NSString*)rootPath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WebDavClient* wdc = [[WebDavManager sharedManager] clientWithUrl:self.deviceUrl userName:self.deviceUserName andPassword:self.devicePassword];
        [wdc listRequest:rootPath seccuss:^(NSArray* items) {
            __block NSArray* bitems = [NSArray arrayWithArray:items];
            __block NSString* brootPath = rootPath;
            dispatch_async(dispatch_get_main_queue(), ^() {
                for (WebDavItem* wbitem in bitems) {
                    FileSystemItem* item = [NSEntityDescription insertNewObjectForEntityForName:@"FileSystemItem" inManagedObjectContext:[InMemmoryCoreDataManager sharedManager].managedObjectContext];
                
                    item.rootPath = brootPath;
                    [item setName:wbitem.name];
                    
                    NSLog(@"%@  %@  %@", item.name, item.lowercaseName, item.lowercaseNameFirstFolders);
                    
                    item.url = wbitem.url;
                    item.isFolder = wbitem.isFolder;
                    item.createTime = wbitem.createDate;
                    item.modifyTime = wbitem.modifyDate;
                    item.llFileSize = wbitem.contentLength;
                }
                [[InMemmoryCoreDataManager sharedManager] saveContext];
            });
        } fail:^(int code, NSString* message) {
            NSLog(@"Fail checkRequest SDCard: (%d) %@", code, message);
        }];

    });
}


@end
