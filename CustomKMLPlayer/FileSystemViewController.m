//
//  FileSystemViewController.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 03.06.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "FileSystemViewController.h"
#import "FileSystemTableViewCell.h"
#import "FileSystem.h"
#import "FileSystemItem.h"
#import "FileSystemItem+More.h"

#import <CoreData/NSFetchedResultsController.h>


@interface FileSystemViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) FileSystem* fileSystem;
@property (strong, nonatomic) NSString* rootPath;
@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;


@end

@implementation FileSystemViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.fileSystem update:self.rootPath];
    [self updateFetchedResultsController];
}

- (void)setRootPath:(NSString*)path ofFileSystem:(FileSystem*)fileSystem {
    self.rootPath = path;
    self.fileSystem = fileSystem;
}


#pragma mark - help methods

- (void)updateFetchedResultsController {
    NSString* filter = @"";
    FileSystemItemFilterType type = FileSystemItemFilterTypeAll;
    BOOL isGroupFolder = NO;
    FileSystemFileSort sort = FileSystemFileSortNameAsc;
    
    self.fetchedResultsController = [self.fileSystem fileSystemFetchedResultsControllerByRootPath:self.rootPath filter:filter type:type andGroupFolder:isGroupFolder sortBy:sort];
    self.fetchedResultsController.delegate = self;
    [self.tableView reloadData];
}

- (void)configureCell:(FileSystemTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    FileSystemItem* fsi = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell update:fsi];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellFile = @"cellFile";
    
    FileSystemTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellFile];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileSystemItem* fsi = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    FileSystemViewController* fsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FileSystemViewController"];
    
    [fsvc setRootPath:[NSString stringWithFormat:@"%@%@/", self.rootPath, fsi.name] ofFileSystem:self.fileSystem];
    
    [self.navigationController pushViewController:fsvc animated:YES];

}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(FileSystemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
