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
#import "CRKConversation.h"
#import "CRKConversationTableViewCell.h"

#import "CRKConversationViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "CRKSettingsViewController.h"

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
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CRKConversation entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastUpdatedDate" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.resultsDataSource = [[MDMFetchedResultsTableDataSource alloc] initWithTableView:self.tableView fetchedResultsController:self.fetchedResultsController];
    self.resultsDataSource.delegate = self;
    self.resultsDataSource.reuseIdentifier = @"CRKConvoCell";
    
    self.tableView.dataSource = self.resultsDataSource;
    self.tableView.delegate = self;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
                                              
- (void)showSettings:(id)sender {
    CRKSettingsViewController *settingsVC = [[CRKSettingsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - MDMFetchedResultsTableDataSourceDelegate

- (void)dataSource:(MDMFetchedResultsTableDataSource *)dataSource configureCell:(id)cell withObject:(id)object{
    CRKConversation *conversation = (CRKConversation *)object;
    
    CRKConversationTableViewCell *uCell = (CRKConversationTableViewCell *)cell;
    
    uCell.contactNameLabel.text = conversation.user.displayName ?: conversation.user.id.UUIDString;
}

#pragma mark - UITableViewDelegate


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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CRKConversationViewController class]]) {
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        CRKConversation *conversation = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        
        CRKConversationViewController *viewController = (CRKConversationViewController *)segue.destinationViewController;
        viewController.conversation = conversation;
        viewController.readContext = [CRKCoreDataHelper sharedHelper].managedObjectContext;
        viewController.sender = [CRKUser currentUserInContext:viewController.readContext];
    }
}

@end
