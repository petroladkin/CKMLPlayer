//
//  FileSystemItem.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FileSystemItem : NSManagedObject

@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSNumber * fileSize;
@property (nonatomic, retain) NSNumber * fileType;
@property (nonatomic, retain) NSNumber * folder;
@property (nonatomic, retain) NSString * lowercaseName;
@property (nonatomic, retain) NSNumber * mediaDuration;
@property (nonatomic, retain) NSDate * modifyTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * rootPath;
@property (nonatomic, retain) NSNumber * subFilesCount;
@property (nonatomic, retain) NSNumber * subFilesSize;
@property (nonatomic, retain) NSNumber * subFoldersCount;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * lowercaseNameFirstFolders;

@end
