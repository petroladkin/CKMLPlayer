//
//  PlayerViewController.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 29.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlayerViewController : UIViewController


@property (strong, nonatomic) NSArray* files;
@property (assign, nonatomic) NSInteger currentFileIndex;


@end
