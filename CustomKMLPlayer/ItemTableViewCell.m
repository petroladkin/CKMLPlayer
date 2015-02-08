//
//  ItemTableViewCell.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 27.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "TableItem.h"


@interface ItemTableViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;


@end


@implementation ItemTableViewCell


- (void)awakeFromNib {
}

- (void)update:(TableItem*)item {
    self.typeImageView.image = [UIImage imageNamed:@"file_icon"];
    
    self.nameLabel.text = item.name;
    self.infoLabel.text = item.info;
}


@end
