//
//  newBookingControlller.m
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "SearchableUITableViewController.h"
#import "iOdysseyAppDelegate.h"
#import "UILabelWithTopbarBG.h"

//#import "DetailViewController.h"

@implementation SearchableUITableViewController

@synthesize tableView;
@synthesize searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 520)];
	
	UILabel *topLabel = [[UILabelWithTopbarBG alloc] initWithFrame:CGRectMake(0, 0, 1024, 45)];
	topLabel.text = @"Pick client for new booking";
	topLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 14.0];
	topLabel.textColor = [UIColor whiteColor];
	topLabel.textAlignment = UITextAlignmentCenter;

	UISearchBar *temp = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 45, 1024, 45)];
	temp.barStyle=UIBarStyleBlackTranslucent;
	temp.showsCancelButton=NO;
	temp.autocorrectionType=UITextAutocorrectionTypeNo;
	temp.autocapitalizationType=UITextAutocapitalizationTypeNone;
	temp.delegate=self;
	temp.backgroundColor = [UIColor whiteColor];
	
	UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 1024, 768-90)];

	table.dataSource = self;
	table.delegate = self;
	
	[view addSubview:topLabel];
	[view addSubview:temp];
	[view addSubview:table];

	tableView = table;
	searchBar = temp;
	[temp release];
	[topLabel release];
	[table release];
	
	self.view = view;
	self.searchBar =searchBar;

	searching = NO;
	letUserSelectRow = YES;
}

-(void)initData
{
	//Initialize the array.
	listOfItems = [[NSMutableArray alloc] init];

	/*
	 The basic thing to remember is this:
	 You must balance every call to "init", "retain" or "copy" with a corresponding call to "release" or "autorelease". That's really all that you need to know.
	 */
	
	int i=0;
	for(int l=0;l<27;l++)
		{
		NSMutableArray *startsWith = [[NSMutableArray alloc] init];
		unichar letterBase = L'A' + l-1;
		unichar xstopLetter = L'A' + l;
		NSString* letter = [NSString stringWithCharacters:&letterBase length:1];
		NSString* stopLetter = [NSString stringWithCharacters:&xstopLetter length:1];
		
//		Dlog(@"Base %@ Stop %@", letter, stopLetter);
		
		ClientInfo *C = [AppDelegate.clientData GetClientByIndex:i++];
		
		//		for(int i=0;i<[AppDelegate.clientData Count]; i++)
		while(C != nil && ![C->CL_NAME hasPrefix:stopLetter] )
			{
			[startsWith addObject:C->CL_NAME];
			C = [AppDelegate.clientData GetClientByIndex:i++];
			}
		i--;
		NSDictionary *startsWithDict = [NSDictionary dictionaryWithObject:startsWith forKey:letter];
		[listOfItems addObject:startsWithDict];
		[startsWith release];
		}
	
	//	[listOfItems addObject:countriesToLiveInDict];
	//	[listOfItems addObject:countriesLivedInDict];
	
	//Initialize the copy array.
//	DLog(@"%@", listOfItems);
	copyListOfItems = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	searchBar.text = @"";
	searching = NO;
	[copyListOfItems removeAllObjects];

	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


/// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	if (searching)
		return 1;
	else
		return [listOfItems count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (searching)
		return [copyListOfItems count];
	else {
		//Number of rows it should expect should be based on the section
		NSDictionary *dictionary = [listOfItems objectAtIndex:section];

		int l=section;
		unichar letterBase = L'A'-1+l;
		NSString* letter = [NSString stringWithCharacters:&letterBase length:1];
		
		NSArray *array = [dictionary objectForKey:letter];
		return [array count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(searching)
		return @"Search Results";

	int l=section;
	unichar letterBase = L'A'-1+l;
	NSString* letter = [NSString stringWithCharacters:&letterBase length:1];

	return letter;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	
	if(searching)
		return nil;
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for(int l=0;l<27;l++)
		{
		unichar letterBase = L'A' + l-1;
		NSString* letter = [NSString stringWithCharacters:&letterBase length:1];
		[tempArray addObject:letter];
		}
	return tempArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

	if(searching)
		return -1;
	
	return index;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([searchBar.text isEqualToString:@""])
		{
		searching = NO;
		letUserSelectRow = YES;
		//	self.tableView.scrollEnabled = NO;
		}
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	if(searching) 
		[cell.textLabel setText:[copyListOfItems objectAtIndex:indexPath.row]];
	else {
		
		//First get the dictionary object
		NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];

		int l=indexPath.section;
		unichar letterBase = L'A' - 1 + l;	//@
		NSString* letter = [NSString stringWithCharacters:&letterBase length:1];
		
		NSArray *array = [dictionary objectForKey:letter];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		[cell.textLabel setText:cellValue];
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Get the selected country
	
	NSString *selectedClient = nil;
	
	if(searching)
		selectedClient = [copyListOfItems objectAtIndex:indexPath.row];
	else {
		NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
		int l=indexPath.section;
		unichar letterBase = L'A' - 1 + l;	//@
		NSString* letter = [NSString stringWithCharacters:&letterBase length:1];
		NSArray *array = [dictionary objectForKey:letter];
		selectedClient = [array objectAtIndex:indexPath.row];
	}
	
	DLog(@"Selected: %@", selectedClient);
	
	[searchBar resignFirstResponder];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"userPickedClient" object:selectedClient]; //Close popup
	
//	[self dismissModalViewControllerAnimated:YES];
	
	/*	
	//Initialize the detail view controller and display it.
	DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	dvController.selectedCountry = selectedCountry;
	[self.navigationController pushViewController:dvController animated:YES];
	[dvController release];
	dvController = nil;
 */
}
-(void) dismissView
{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(letUserSelectRow)
		return indexPath;
	else
		return nil;
}
/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	//return UITableViewCellAccessoryDetailDisclosureButton;
	//return UITableViewCellAccessoryDisclosureIndicator;
	return UITableViewCellAccessoryNone;
}
*/
/*
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	
//	AppDelegate.
	
	if ([searchBar.text isEqualToString:@""])
		{
		searching = NO;
		letUserSelectRow = YES;
		}	
	//This method is called again when the user clicks back from the detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;
	
	searching = YES;
//	letUserSelectRow = NO;
//	self.tableView.scrollEnabled = NO;
	
	//Add the done button.
//	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSearching_Clicked:)] autorelease];

	[searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {

	//Remove all objects first.
	[copyListOfItems removeAllObjects];
	
	if([searchText length] > 0) {
		searching = YES;
		letUserSelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		searching = NO;
//		letUserSelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[self searchTableView];
}

- (void) searchTableView {
	
	NSString *searchText = searchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];

	
	for(int l=0;l<27;l++)
		{
		unichar letterBase = L'A' + l-1;
		NSString* letter = [NSString stringWithCharacters:&letterBase length:1];
		NSDictionary *dictionary = [listOfItems objectAtIndex:l];
		NSArray *array = [dictionary objectForKey:letter];
		[searchArray addObjectsFromArray:array];
		}

	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[copyListOfItems addObject:sTemp];
	}
	
	[searchArray release];
	searchArray = nil;
}

- (void) doneSearching_Clicked:(id)sender {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[self.tableView reloadData];
}

- (void)dealloc {
	
	[copyListOfItems release];
	[searchBar release];
	[listOfItems release];
    [super dealloc];
}


@end

