//
//  InMemmoryCoreDataManager.h
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 04.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NSManagedObjectContext;


@interface InMemmoryCoreDataManager : NSObject


+ (InMemmoryCoreDataManager*)sharedManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;


@end
