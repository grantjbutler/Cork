//
//  CRKConversationsTableViewController.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKConversationsTableViewController.h"
#import "CRKCoreDataHelper.h"
#import "NSManagedObject+CRKAdditions.h"
#import "CRKUser.h"
#import "CRKConversationTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CRKConversationsTableViewController ()

@property CRKCoreDataHelper *coreDataHelper;
@property NSManagedObjectContext *managedObjectContext;
@property NSFetchedResultsController *fetchedResultsController;
@property MDMFetchedResultsTableDataSource *resultsDataSource;

@end

@implementation CRKConversationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coreDataHelper = [CRKCoreDataHelper sharedHelper];
    self.managedObjectContext = self.coreDataHelper.persistenceController.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CRKUser"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isContact == YES"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.resultsDataSource = [[MDMFetchedResultsTableDataSource alloc] initWithTableView:self.tableView fetchedResultsController:self.fetchedResultsController];
    self.resultsDataSource.delegate = self;
    self.resultsDataSource.reuseIdentifier = @"CRKConvoCell";
    
    self.tableView.dataSource = self.resultsDataSource;
    self.tableView.delegate = self;
    
    
    UIBarButtonItem *myUserIDBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(userIDBarButtonPressed)];
    
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(compose)];
    
    self.navigationItem.leftBarButtonItem = myUserIDBarButtonItem;
    self.navigationItem.rightBarButtonItem = composeBarButtonItem;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
                                              
- (void)userIDBarButtonPressed{
    NSUUID *uuid = [CRKUser currentUserID];
    
    [[UIPasteboard generalPasteboard] setString:uuid.UUIDString];
    [SVProgressHUD showInfoWithStatus:@"UserID copied to pasteboard"];
}

- (void)compose{
    //TODO: Compose
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MDMFetchedResultsTableDataSourceDelegate

- (void)dataSource:(MDMFetchedResultsTableDataSource *)dataSource configureCell:(id)cell withObject:(id)object{
    CRKUser *user = (CRKUser *)object;
    
    CRKConversationTableViewCell *uCell = (CRKConversationTableViewCell *)cell;
    
    uCell.contactNameLabel.text = user.displayName;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CRKUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
