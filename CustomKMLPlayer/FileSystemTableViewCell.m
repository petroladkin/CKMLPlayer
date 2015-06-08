//
//  FileTableViewCell.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystemTableViewCell.h"
#import "FileSystemItem.h"
#import "FileSystemItem+More.h"


@interface FileSystemTableViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoRightLabel;


@end


@implementation FileSystemTableViewCell


- (void)awakeFromNib {
}

- (void)update:(FileSystemItem*)item {
    //TODO: add parse image
    if (item.thumbnail != nil) {
        self.iconImageView.image = item.imageThumbnail;
    } else {
        self.iconImageView.image = [UIImage imageNamed:(item.isFolder ? @"folder_icon" : @"file_icon")];
    }
    
    self.nameLabel.text = item.name;
    
    self.infoLeftLabel.hidden = YES;
    self.infoRightLabel.hidden = YES;
}



@end
