//
//  LoginController.m
//  iOdyssey
//
//  Created by Michael Holm on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "TextInputCell.h"
#import "BoolInputCell.h"
#import "iOdysseyAppDelegate.h"

@implementation LoginController

@synthesize table, HasBeenLoggedInOK, isPushed, isDisplayingModalVewController;

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
	return 1;	// Username/password + remember password
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch(section)
	{
		case 0:	return @"Login Credentials"; break;//User name/password
		case 1:	return @"Remember Login Credentials?"; break;// remember password
	}
	return @"ERROR 0x2343243";
}


-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch(section)
	{
		case 0:	return 2; break;
		case 1:	return 1; break;
	}
	return 1;	// Login, password, remember password
}

/*
 - (void)characterEntered:(id)sender
 {
 for (int i=0; i<[table numberOfRowsInSection:0]; i++)
 {
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0 ];
 
 UITableViewCell *activeCell = (UITableViewCell *)[table cellForRowAtIndexPath:indexPath];
 
 if( [activeCell isKindOfClass:[TextInputCell class]] )
 {
 TextInputCell *cell = (TextInputCell*)activeCell;
 if(cell.value == sender)
 {
 
 break;
 }
 }
 }
 }
 */
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
				[[cell Label] setText:@"Login"];
				[[cell value] setText:AppDelegate.loginData.loginName];
				[[cell value] setAutocorrectionType:UITextAutocorrectionTypeNo];
				break;
				case 1:
				[[cell Label] setText:@"Password"];
				[[cell value] setText:AppDelegate.loginData.password];
				[[cell value] setSecureTextEntry:YES];
				[[cell value] setAutocorrectionType:UITextAutocorrectionTypeNo];
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

-(IBAction) DoLogin:(id)sender
{
	// check username and password
	
	for (int i=0; i<[table numberOfRowsInSection:0]; i++)
		{
		cout << i << endl;
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0 ];
		
		UITableViewCell *activeCell = (UITableViewCell *)[table cellForRowAtIndexPath:indexPath];
		
		if( [activeCell isKindOfClass:[TextInputCell class]] )
			{
			TextInputCell *cell = (TextInputCell*)activeCell;
			if([cell.Label.text compare:@"Login"] == NSOrderedSame)
				AppDelegate.loginData.loginName = cell.value.text;
			else if([cell.Label.text compare:@"Password"] == NSOrderedSame)
				AppDelegate.loginData.password = cell.value.text;
			cout << "SETTING PASSWORD AND USERNAME" << endl;
			}
		}
	
	[AppDelegate.loginData RequestLoginData];
}

-(IBAction) LoginOK
{
	HasBeenLoggedInOK = YES;
	cout << "loginOK" << endl;
	
	cout << "AppDelegate.loginData.loginName: " << [AppDelegate.loginData.loginName UTF8String] << endl;
	if([AppDelegate isDoneGettingInitData] == YES)
		{
		if(isPushed == YES)
			{
			cout << "Pop Login controller" << endl;
			[AppDelegate.preferencesController.table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
			[self.navigationController popViewControllerAnimated:YES];
			}
		else
			{
			cout << "Dismiss Login controller" << endl;
			[AppDelegate.viewController dismissModalViewControllerAnimated:NO];
			}
		}
	else // Showed during first init
		{
		[AppDelegate.splashView setAlpha:1.0f];
		cout << "Dismiss Login controller" << endl;
		[AppDelegate.splashViewController dismissModalViewControllerAnimated:NO];
		}
}

-(IBAction) LoginFailed
{
	HasBeenLoggedInOK = NO;
	cout << "LoginFailed" << endl;
	if(isDisplayingModalVewController == YES)
		return;
	if([AppDelegate isDoneGettingInitData] == NO)
		{
//		[AppDelegate.splashView setAlpha:0.0f];
		if(HasBeenLoggedInOK == NO)
			{
			isPushed=NO;
			isDisplayingModalVewController=YES;
			[AppDelegate.splashViewController presentModalViewController:self animated:NO];
			}
		}
}

@end
















