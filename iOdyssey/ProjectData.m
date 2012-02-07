//
//  ProjectData.m
//  iOdyssey
//
//  Created by Kulitorum on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ProjectData.h"
#import "iOdysseyAppDelegate.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "UILabelWithTopbarBG.h"

@implementation ProjectData

@synthesize tableView;

- (id)init
{
    self = [super init];
    if (self)
		{
		}
    
    return self;
}
-(ProjectInfo*)GetProject:(int) PR_KEY
{
	for(int i=0;i<projects.size();i++)
		if(projects[i].PR_KEY == PR_KEY)
			return &projects[i];
	return &projects[0];
}

-(ProjectInfo*)GetProjectByIndex:(int)index
{
	if(index >= projects.size())
		return nil;
	return &projects[index];
}
-(int)Count
{
	return projects.size();
}

- (void)RequestProjectData:(int)CL_KEY
{
    cout << "Request Project Data" << endl;

	//SELECT PR_KEY, PR_NAME FROM dbo.CPF_PROJECT WHERE CL_KEY = 2037 AND closed <> 1 AND SITE_KEY = 9999
	
	NSString *request = [NSString stringWithFormat:@"select PR_KEY, PR_NAME FROM dbo.CPF_PROJECT WHERE CL_KEY = %d AND closed <> 1 AND SITE_KEY = %d ORDER BY PR_NAME",CL_KEY, AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	cout << "Got Project Data, Processing" << endl;
	projects.clear();

	//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];

	//NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];

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
			NSInteger PR_KEY = [resultSet indexForField:@"PR_KEY"];
			NSInteger PR_NAME = [resultSet indexForField:@"PR_NAME"];
			
			ProjectInfo C;
#ifdef ALLOW_NO_PROJECT_AND_FOLDER
			C.PR_KEY = -1;
			C.PR_NAME = @"No project selected";
			projects.push_back(C);
			
#endif			
			while ([resultSet moveNext])
				{
				C.PR_KEY = [ resultSet getInteger: PR_KEY ];
				if(C.PR_KEY <= 0)
					continue;
				
				NSString *NAME = [resultSet getString: PR_NAME];
				if(NAME != nil && ([NAME isKindOfClass:[NSString class]] == YES))
					C.PR_NAME = [NAME retain];
				else
					continue;
				projects.push_back(C);
				}
			
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}

	for(int i=0;i<projects.size();i++)
		DLog(@"Project: %@, ID:%d", projects[i].PR_NAME, projects[i].PR_KEY);


	[AppDelegate->clientSearchController dismissView];
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
	return projects.size();
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ProjectCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	[cell.textLabel setText:projects[indexPath.row].PR_NAME];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Get the selected country
	
	ProjectInfo selectedProject = projects[indexPath.row];
	
	DLog(@"Selected Project: %@", selectedProject.PR_NAME);

	NSNumber *pid = [NSNumber numberWithInt:selectedProject.PR_KEY];
	[self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userPickedProject" object:pid]; //Close popup
}

@end
