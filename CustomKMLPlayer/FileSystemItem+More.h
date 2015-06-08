//
//  FileSystemItem+More.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystemItem.h"


typedef NS_ENUM(NSUInteger, FileSystemItemType) {
    FileSystemItemTypeUnknown,
    FileSystemItemTypeVideo,
    FileSystemItemTypeImage,
    FileSystemItemTypeMusic
};


@class UIImage;


@interface FileSystemItem (More)


@property (nonatomic, assign) BOOL isFolder;
@property (nonatomic, assign) UIImage* imageThumbnail;
@property (nonatomic, assign) int iSubFoldersCount;
@property (nonatomic, assign) int iSubFilesCount;
@property (nonatomic, assign) long long llSubFilesSize;
@property (nonatomic, assign) long long llFileSize;
@property (nonatomic, assign) double dMediaDuration;
@property (nonatomic, assign) FileSystemItemType eFileType;


- (void)setName:(NSString*)name isFolder:(BOOL)isFolder;


@end
