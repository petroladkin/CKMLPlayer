//
//  GroupTableViewCell.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 27.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "GroupTableViewCell.h"
#import "TableItem.h"


@interface GroupTableViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;


@end


@implementation GroupTableViewCell


- (void)awakeFromNib {
}


- (void)update:(TableItem*)item {
    switch (item.type) {
        case ETableItemTypeDevice:
            self.typeImageView.image = [UIImage imageNamed:@"device_icon"];
            break;
        case ETableItemTypeFolder:
            self.typeImageView.image = [UIImage imageNamed:@"folder_icon"];
            break;
    }
        
    self.nameLabel.text = item.name;
    self.infoLabel.text = item.info;
}


@end
