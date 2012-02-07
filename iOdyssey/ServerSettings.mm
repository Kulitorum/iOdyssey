//
//  LoginController.m
//  iOdyssey
//
//  Created by Michael Holm on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerSettings.h"
#import "TextInputCell.h"
#import "BoolInputCell.h"
#import "iOdysseyAppDelegate.h"

@implementation ServerSettings

@synthesize table;

- (void)dealloc
{
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}


-(void) RefreshView
{
	[table reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;	// Server/Database + Username/password
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Server Settings";
}


-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	
	switch(section)
	{
		case 0:	return 2; break; // 4 to include username and password for server (not login)
		case 1:	return 1; break;
	}
	return 1;	// Login, password, remember password
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch(indexPath.section)
	{
		case 0:
		{
		static NSString *CellIdentifier = @"TextInputCellID";
		TextInputCell *cell = (TextInputCell *)[table dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
			{
//			DLog(@"New Cell Made");
			
			NSString *nibName;
			if(AppDelegate.IsIpad)
				nibName = @"TextInputCell_ipad";
			else
				nibName = @"TextInputCell_iphone";
			
			NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
			for(id currentObject in topLevelObjects)
				{
				if([currentObject isKindOfClass:[UITableViewCell class]])
					{
					cell = (TextInputCell *)currentObject;
					break;
					}
				}
			}
		
		[[cell value] setText:@""];
		switch(indexPath.row)
			{
				case 0:
				[[cell Label] setText:@"Server"];
				[[cell value] setText:AppDelegate.SettingsServer];
				ServerCell = cell;
				break;
				case 1:
				[[cell Label] setText:@"Database"];
				[[cell value] setText:AppDelegate.SettingsDatabase];
				DatabaseCell = cell;
				break;
				case 2:
				[[cell Label] setText:@"Username"];
				[[cell value] setText:AppDelegate.SettingsUsername];
				UsernameCell = cell;
				break;
				case 3:
				[[cell Label] setText:@"Password"];
				[[cell value] setText:AppDelegate.SettingsPassword];
				PasswordCell = cell;
				break;
			}
		//		[[cell value] addTarget:self action:@selector(characterEntered:) forControlEvents:UIControlEventEditingChanged];
		return cell;
		break;
		}
		case 1:	// remember password
		{
		static NSString *CellIdentifier = @"BoolInputCellID";
		BoolInputCell *cell = (BoolInputCell *)[table dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
			{
			DLog(@"New BoolInputCell Cell Made");
			
			NSString *nibName;
			if(AppDelegate.IsIpad)
				nibName = @"BoolInputCell_ipad";
			else
				nibName = @"BoolInputCell_iPhone";
			
			NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
			for(id currentObject in topLevelObjects)
				{
				if([currentObject isKindOfClass:[UITableViewCell class]])
					{
					cell = (BoolInputCell *)currentObject;
					break;
					}
				}
			}
		
		[[cell value] setOn:YES];
		[[cell Label] setText:@"Remember"];
		return cell;
		break;
		}
	}
	BoolInputCell *cell;
	[cell.value setOn:YES];
	[cell.Label setText:@"This is fucked"];
	return cell;
}

-(IBAction) Return:(id)sender
{
	AppDelegate.SettingsServer = ServerCell.value.text;
	AppDelegate.SettingsDatabase = DatabaseCell.value.text;
		//	AppDelegate.SettingsUsername = UsernameCell.value.text;
		//	AppDelegate.SettingsPassword = PasswordCell.value.text;
	
	[self.navigationController popViewControllerAnimated:YES];
}


@end

































