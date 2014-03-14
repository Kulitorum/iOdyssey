//
//  theNewBookingControlller.h
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@interface SearchableUITableViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
	NSMutableArray *listOfItems;
	NSMutableArray *copyListOfItems;
	UISearchBar *searchBar;
	BOOL searching;
	BOOL letUserSelectRow;
	UITableView *tableView;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UISearchBar *searchBar;


- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;
-(void)initData;
-(void) dismissView;

@end
