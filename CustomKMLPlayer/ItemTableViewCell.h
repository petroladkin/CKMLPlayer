//
//  ItemTableViewCell.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 27.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TableItem;


@interface ItemTableViewCell : UITableViewCell


- (void)update:(TableItem*)item;


@end
