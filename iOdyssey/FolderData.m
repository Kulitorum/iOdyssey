//
//  FolderData.m
//  iOdyssey
//
//  Created by Kulitorum on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
//  FolderData.m
//  iOdyssey
//
//  Created by Michael Holm on 05/10/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

#import "FolderData.h"

//
//  ColorData.m
//  iOdyssey
//
//  Created by Kulitorum on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FolderData.h"
#import "iOdysseyAppDelegate.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "UILabelWithTopbarBG.h"

//SELECT PR_ID, PR_NAME FROM dbo.CPF_PROJECT WHERE CL_KEY = 2037 AND closed <> 1 AND SITE_KEY = 9999
//SELECT WO_KEY, NAME FROM dbo.CPF_FOLDER WHERE PR_KEY = 5276
@implementation FolderData

@synthesize tableView;

- (id)init
{
    self = [super init];
    if (self)
		{
		}
    
    return self;
}
-(FolderInfo*)GetFolder:(int)WO_KEY
{
	for(int i=0;i<folders.size();i++)
		if(folders[i].WO_KEY == WO_KEY)
			return &folders[i];
	return &folders[0];
}

-(FolderInfo*)GetFolderByIndex:(int)index
{
	if(index >= folders.size())
		return nil;
	return &folders[index];
}
-(int)Count
{
	return folders.size();
}

- (void)RequestFolderData:(int)PR_KEY
{
    cout << "Request Folder Data" << endl;
	
	NSString *request = [NSString stringWithFormat:@"SELECT WO_KEY, NAME FROM dbo.CPF_FOLDER WHERE PR_KEY = %d AND SITE_KEY=%d",PR_KEY, AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
}


- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	cout << "Got Folder Data, Processing" << endl;
	folders.clear();
	//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
/*			for (int i = 0; i < resultSet.fieldCount; i++)
				{
				[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
				}
			[outputString appendString:@"\r\n--------\r\n"];
*/			
			
			NSInteger WO_KEY = [resultSet indexForField:@"WO_KEY"];
			NSInteger NAME = [resultSet indexForField:@"NAME"];
			
			FolderInfo C;
#ifdef ALLOW_NO_PROJECT_AND_FOLDER

			C.WO_KEY = -100;
			C.NAME = @"No folder selected";
			folders.push_back(C);
#endif
			while ([resultSet moveNext])
				{
				C.WO_KEY = [ resultSet getInteger: WO_KEY ];
				if(C.WO_KEY <= 0)
					continue;
				
				NSString *FOLDERNAME = [resultSet getString: NAME];
				if(FOLDERNAME != nil && ([FOLDERNAME isKindOfClass:[NSString class]] == YES))
					C.NAME = [FOLDERNAME retain];
				else
					continue;
				folders.push_back(C);
				}
			
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
}


-(void)viewWillAppear:(BOOL)animated
{
//	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 520)];
	
	UILabel *topLabel = [[UILabelWithTopbarBG alloc] initWithFrame:CGRectMake(0, 0, 1024, 45)];
	topLabel.text = @"Pick folder for new booking";
	topLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 14.0];
	topLabel.textColor = [UIColor whiteColor];
	topLabel.textAlignment = UITextAlignmentCenter;
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, AppDelegate->ganttDisplayWidth, AppDelegate->ganttDisplayHeight-45)];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	[self.view addSubview:topLabel];
	[self.view addSubview:self.tableView];
	[topLabel release];
}

/// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return folders.size();
}

-(void)clear
{
	folders.clear();
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ProjectCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	[cell.textLabel setText:folders[indexPath.row].NAME];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Get the selected country
	
	FolderInfo selectedProject = folders[indexPath.row];
	
	DLog(@"Selected Project: %@", selectedProject.NAME);
	
	NSNumber *pid = [NSNumber numberWithInt:selectedProject.WO_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userPickedFolder" object:pid]; //Close popup

	[self dismissModalViewControllerAnimated:YES];
}



@end

