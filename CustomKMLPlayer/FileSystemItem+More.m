//
//  FileSystemItem+More.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystemItem+More.h"
#import <UIKit/UIKit.h>


@implementation FileSystemItem (More)


- (BOOL)isFolder {
    return [self.folder boolValue];
}

- (void)setIsFolder:(BOOL)isFolder {
    self.folder = [NSNumber numberWithBool:isFolder];
}

- (UIImage*)imageThumbnail {
    return [UIImage imageWithData:self.thumbnail];
}

- (void)setImageThumbnail:(UIImage *)imageThumbnail {
    self.thumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.0);
}

- (int)iSubFoldersCount {
    return [self.subFoldersCount intValue];
}

- (void)setISubFoldersCount:(int)iSubFoldersCount {
    self.subFoldersCount = [NSNumber numberWithInt:iSubFoldersCount];
}

- (int)iSubFilesCount {
    return [self.subFilesCount intValue];
}

- (void)setISubFilesCount:(int)iSubFilesCount {
    self.subFilesCount = [NSNumber numberWithInt:iSubFilesCount];
}

- (long long)llSubFilesSize {
    return [self.subFilesSize longLongValue];
}

- (void)setLlSubFilesSize:(long long)llSubFilesSize {
    self.subFilesSize = [NSNumber numberWithLongLong:llSubFilesSize];
}

- (long long)llFileSize {
    return [self.fileSize longLongValue];
}

- (void)setLlFileSize:(long long)llFileSize {
    self.fileSize = [NSNumber numberWithLongLong:llFileSize];
}

- (double)dMediaDuration {
    return [self.mediaDuration doubleValue];
}

- (void)setDMediaDuration:(double)dMediaDuration {
    self.mediaDuration = [NSNumber numberWithDouble:dMediaDuration];
}

- (FileSystemItemType)eFileType {
    return (FileSystemItemType)[self.fileType shortValue];
}

- (void)setEFileType:(FileSystemItemType)eFileType {
    self.fileType = [NSNumber numberWithShort:eFileType];
}

- (void)setName:(NSString*)name isFolder:(BOOL)isFolder {
    self.name = name;
    self.lowercaseName = name.lowercaseString;
    self.lowercaseNameFirstFolders = [NSString stringWithFormat:@"%@%@", (isFolder ? @" " : @""), self.lowercaseName];
}


@end
