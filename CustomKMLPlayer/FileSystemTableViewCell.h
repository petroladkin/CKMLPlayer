//
//  FileTableViewCell.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FileSystemItem;


@interface FileSystemTableViewCell : UITableViewCell


- (void)update:(FileSystemItem*)item;


@end
