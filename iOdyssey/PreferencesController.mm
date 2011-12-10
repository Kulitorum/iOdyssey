//
//  PreferencesController.m
//  iOdyssey
//
//  Created by Michael Holm on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"
#import "iOdysseyAppDelegate.h"
#import "DropDownCell.h"

@implementation PreferencesController

@synthesize table, DataScopeBack, DataScopeForward, GanttViewScope, ShowLineForEveryLine;

-(IBAction) Return:(id)sender
{
	// Copy out the values
	
	//DataScopeBack
	NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	AppDelegate.DataScopeBack = [[dropDown1 stringByTrimmingCharactersInSet:nonDigits ] intValue];
	AppDelegate.DataScopeForward = [[dropDown2 stringByTrimmingCharactersInSet:nonDigits ] intValue];
	AppDelegate.GanttViewScope = [[dropDown3 stringByTrimmingCharactersInSet:nonDigits ] intValue];
	AppDelegate.ShowLineForEveryLine = [[dropDown4 stringByTrimmingCharactersInSet:nonDigits ] intValue];
	if(AppDelegate.ShowLineForEveryLine == 0)
		AppDelegate.ShowLineForEveryLine=1;

	if ([dropDown5 compare:@"Booking name"] == NSOrderedSame) AppDelegate.GanttSlotNamesStyle=BOOKINGNAMESTYLE;
	else if ([dropDown5 compare:@"Client"] == NSOrderedSame) AppDelegate.GanttSlotNamesStyle=CLIENTSTYLE;
	else if ([dropDown5 compare:@"Project"] == NSOrderedSame) AppDelegate.GanttSlotNamesStyle=PROJECTSTYLE;
	else if ([dropDown5 compare:@"Activity"] == NSOrderedSame) AppDelegate.GanttSlotNamesStyle=ACTIVITYSTYLE;
	else if ([dropDown5 compare:@"Booking id"] == NSOrderedSame) AppDelegate.GanttSlotNamesStyle=BOOKINGIDSTYLE;

	cout << "Prefs: DataScopeBack " << AppDelegate.DataScopeBack << endl;
	cout << "Prefs: DataScopeForward " << AppDelegate.DataScopeForward << endl;
	cout << "Prefs: GanttViewScope " << AppDelegate.GanttViewScope << endl;
	cout << "Prefs: ShowLineForEveryLine " << AppDelegate.ShowLineForEveryLine << endl;
	
	[AppDelegate.ganttviewcontroller RefreshBookings];
	[self.navigationController popViewControllerAnimated:YES];
}
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{ 
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(AppDelegate.IsIpad)
		return 40;
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch(section)
	{
		case 0:	return @"Data Scope Backwards"; break;//User name/password
		case 1:	return @"Data Scope Forwards"; break;//User name/password
		case 2:	return @"View Scope"; break;// remember password
		case 3:	return @"Resource Dividers"; break;// remember password
		case 4:	return @"Show Slot Names As"; break;// remember password
		case 5:	return @"Login Credentials"; break;// remember password
		case 6:	return @"Server Settings"; break;// remember password
	}
	return @"ERROR 0x2343243";
}

-(void) RefreshView
{
	cout << " Preferences : RefreshView " << endl;
	[table reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    cout << "PREFERENCES:numberOfSectionsInTableView" << endl;
	return 6;	// Username/password + remember password
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case 0:					// Data scope backwards
            if (dropDown1Open)
                return 6;	// 5+1
            else
                return 1;
            break;
			
        case 1:					// Data scope forwards
            if (dropDown2Open)
                return 8;// 1->7+1
            else
                return 1;
        case 2:					// ViewScope
            if (dropDown3Open)
                return 4;
            else
                return 1;
        case 3:					// Resource dividers
            if (dropDown4Open)
                return 8;
            else
                return 1;
        case 4:					// Show cell names as
            if (dropDown5Open)
                return 6;
            else
                return 1;
        default:
            return 1;
            break;
    }

/*	
	switch(section)
	{
		case 0: return 2; break;// Datascope back, fwd
		case 1: return 1; break;// Viewscope
		case 2: return 1; break;// linesEvery, SlotNames
		case 3: return 1; break;// Combination
		case 4: return 1; break;// Combination
	}*/
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *DropDownCellIdentifier = @"DropDownCell";
    
    switch ([indexPath section]) {
        case 0: {
			
            switch ([indexPath row])
			{
                case 0: {	// Title cell
					
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        DLog(@"New Cell 0 Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        for(id currentObject in topLevelObjects)
							{
                            if([currentObject isKindOfClass:[DropDownCell class]])
								{
                                cell = (DropDownCell *)currentObject;
                                break;
								}
							}
                    }
                    
                    dropDown1 =  [NSString stringWithFormat:(AppDelegate.DataScopeBack == 1 ? @"%d Day": @"%d Days") , AppDelegate.DataScopeBack];
                    [[cell textLabel] setText:dropDown1];
                    
						// Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {	// options (things you can select)
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
					NSString *label = [NSString stringWithFormat: ([indexPath row] == 1 ? @"%i Day" :  @"%i Days"), [indexPath row]];
                    
                    [[cell textLabel] setText:label];
                    
						// Configure the cell.
                    return cell;
                    
                    break;
                }
            }
			
            break;
        }
        case 1: {
			
            switch ([indexPath row]) {
                case 0: {
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        DLog(@"New Cell 1 Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        for(id currentObject in topLevelObjects)
							{
                            if([currentObject isKindOfClass:[DropDownCell class]])
								{
                                cell = (DropDownCell *)currentObject;
                                break;
								}
							}
                    }
                    
                    dropDown2 =  [NSString stringWithFormat:(AppDelegate.DataScopeForward == 1 ? @"%d Day": @"%d Days") , AppDelegate.DataScopeForward];
                    [[cell textLabel] setText:dropDown2];
                    
						// Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
					NSString *label = [NSString stringWithFormat: ([indexPath row] == 1 ? @"%i Day" :  @"%i Days"), [indexPath row]];
                    
                    [[cell textLabel] setText:label];
                    
						// Configure the cell.
                    return cell;
                    
                    break;
                }
            }
            
            break;
        }
        case 2: { // View scope
			
            switch ([indexPath row]) {
                case 0: {
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        DLog(@"New Cell 2 Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        for(id currentObject in topLevelObjects)
							{
                            if([currentObject isKindOfClass:[DropDownCell class]])
								{
                                cell = (DropDownCell *)currentObject;
                                break;
								}
							}
                    }
                    
                    dropDown3 =  [NSString stringWithFormat:(AppDelegate.GanttViewScope == 1 ? @"%d Day": @"%d Days") , AppDelegate.GanttViewScope];
                    [[cell textLabel] setText:dropDown3];
                    
						// Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
					NSString *label = [NSString stringWithFormat: ([indexPath row] == 1 ? @"%i Day" :  @"%i Days"), [indexPath row]];
                    
                    [[cell textLabel] setText:label];
                    
						// Configure the cell.
                    return cell;
                    
                    break;
                }
            }
            
            break;
        }
		case 3:	// Resource dividers
		{
		
		switch ([indexPath row]) {
			case 0: {
				DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
				
				if (cell == nil){
					DLog(@"New Cell 3 Made");
					
					NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
					
					for(id currentObject in topLevelObjects)
						{
						if([currentObject isKindOfClass:[DropDownCell class]])
							{
							cell = (DropDownCell *)currentObject;
							break;
							}
						}
				}
				
				dropDown4 =  [NSString stringWithFormat:(AppDelegate.ShowLineForEveryLine == 1 ? @"Every Resource": @"%d Resources") , AppDelegate.ShowLineForEveryLine];
				[[cell textLabel] setText:dropDown4];
				
					// Configure the cell.
				return cell;
				
				break;
			}
			default: {
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				}
				
				NSString *label = [NSString stringWithFormat: ([indexPath row] == 1 ? @"Every Resource" :  @"%d Resources"), [indexPath row]];
				
				[[cell textLabel] setText:label];
				
					// Configure the cell.
				return cell;
				
				break;
			}
		}
		
		break;
        }
		case 4: // show cell names as
		{
		
		switch ([indexPath row]) {
			case 0: {
				DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
				
				if (cell == nil){
					DLog(@"New Cell 4 Made");
					
					NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
					
					for(id currentObject in topLevelObjects)
						{
						if([currentObject isKindOfClass:[DropDownCell class]])
							{
							cell = (DropDownCell *)currentObject;
							break;
							}
						}
				}
				
				[[cell textLabel] setText:@"Client"];
				dropDown5 = @"Client";
				// Configure the cell.
				return cell;
				
				break;
			}
			default: {
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				}
				
				NSString *label = [NSString stringWithFormat:@"%crap", [indexPath row]];
				
				[[cell textLabel] setText:label];
				
					// Configure the cell.
				switch([indexPath row])
				{
					case 1:[[cell textLabel] setText:@"Booking name"]; break;
					case 2:[[cell textLabel] setText:@"Client"]; break;
					case 3:[[cell textLabel] setText:@"Project"]; break;
					case 4:[[cell textLabel] setText:@"Activity"]; break;
					case 5:[[cell textLabel] setText:@"Booking id"]; break;
				}
				return cell;
				
				break;
			}
		}
		
		break;
        }
		case 5: // login button
		{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		NSString *label = [NSString stringWithFormat:@"%@", AppDelegate.loginData.loginName];
		
		[[cell textLabel] setText:label];
		
			// Configure the cell.
		return cell;
		}
		case 6: // server settings button
		{
		
		}
        default:
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			NSString *label = [NSString stringWithFormat:@"%@", AppDelegate.SettingsServer];
			
			[[cell textLabel] setText:label];
			
				// Configure the cell.
			return cell;
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
    
    switch ([indexPath section]) {
        case 0: {
            switch ([indexPath row]) {	// data scope backwards
                case 0:
                {
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[indexPath row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[indexPath row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[indexPath row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[indexPath row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[indexPath row]+5 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2, path3, path4, nil];
				
				if ([cell isOpen])
                    {
					[cell setClosed];
					dropDown1Open = [cell isOpen];
					
					[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
				else
                    {
					[cell setOpen];
					dropDown1Open = [cell isOpen];
					
					[tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
					[tableView scrollToRowAtIndexPath:path4 atScrollPosition:UITableViewScrollPositionBottom animated:YES];					
                    }
				
				break;
                }   
                default:
                {
				dropDown1 = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
				
				NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:[indexPath section]];
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:path];
				
				[[cell textLabel] setText:dropDown1];
				
				NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
				AppDelegate.DataScopeBack = [[dropDown1 stringByTrimmingCharactersInSet:nonDigits ] intValue];
                    // close the dropdown cell
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[path row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[path row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[path row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[path row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[path row]+5 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2,path3, path4, nil];
				
				[cell setClosed];
				dropDown1Open = [cell isOpen];
				
				[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];

				break;
                }
            }
            
            break;
        }
        case 1: { // data scope forwards
            
            switch ([indexPath row]) {
                case 0:
                {
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[indexPath row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[indexPath row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[indexPath row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[indexPath row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[indexPath row]+5 inSection:[indexPath section]];
				NSIndexPath *path5 = [NSIndexPath indexPathForRow:[indexPath row]+6 inSection:[indexPath section]];
				NSIndexPath *path6 = [NSIndexPath indexPathForRow:[indexPath row]+7 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2, path3, path4, path5, path6, nil];
				
				if ([cell isOpen])
                    {
					[cell setClosed];
					dropDown2Open = [cell isOpen];
					
					[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
				else
                    {
					[cell setOpen];
					dropDown2Open = [cell isOpen];
					
					[tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
					[tableView scrollToRowAtIndexPath:path6 atScrollPosition:UITableViewScrollPositionBottom animated:YES];					
                    }
				
				break;
                }   
                default:
                {
				dropDown2 = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
				
				NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:[indexPath section]];
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:path];
				
				[[cell textLabel] setText:dropDown2];
				
				NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
				AppDelegate.DataScopeForward = [[dropDown2 stringByTrimmingCharactersInSet:nonDigits ] intValue];
					// close the dropdown cell
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[path row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[path row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[path row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[path row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[path row]+5 inSection:[indexPath section]];
				NSIndexPath *path5 = [NSIndexPath indexPathForRow:[path row]+6 inSection:[indexPath section]];
				NSIndexPath *path6 = [NSIndexPath indexPathForRow:[path row]+7 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2,path3, path4, path5, path6,nil];
				
				[cell setClosed];
				dropDown2Open = [cell isOpen];
				
				[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
				break;
                }
            }
            
            break;
        }
        case 2: { // View scope
            
            switch ([indexPath row]) {
                case 0:
                {
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[indexPath row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[indexPath row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[indexPath row]+3 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2, nil];
				
				if ([cell isOpen])
                    {
					[cell setClosed];
					dropDown3Open = [cell isOpen];
					
					[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
				else
                    {
					[cell setOpen];
					dropDown3Open = [cell isOpen];
					
					[tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
					[tableView scrollToRowAtIndexPath:path2 atScrollPosition:UITableViewScrollPositionBottom animated:YES];					
                    }
				
				break;
                }   
                default:
                {
				dropDown3 = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
				
				NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:[indexPath section]];
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:path];
				
				[[cell textLabel] setText:dropDown3];
				
                    // close the dropdown cell
				
				NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
				AppDelegate.GanttViewScope = [[dropDown3 stringByTrimmingCharactersInSet:nonDigits ] intValue];

				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[path row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[path row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[path row]+3 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2,nil];
				
				[cell setClosed];
				dropDown3Open = [cell isOpen];
				
				[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
				
				break;
                }
            }
            
            break;
        }
		case 3: { // resource dividers
            
            switch ([indexPath row]) {
                case 0:
                {
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[indexPath row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[indexPath row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[indexPath row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[indexPath row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[indexPath row]+5 inSection:[indexPath section]];
				NSIndexPath *path5 = [NSIndexPath indexPathForRow:[indexPath row]+6 inSection:[indexPath section]];
				NSIndexPath *path6 = [NSIndexPath indexPathForRow:[indexPath row]+7 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2, path3, path4, path5, path6, nil];
				
				if ([cell isOpen])
                    {
					[cell setClosed];
					dropDown4Open = [cell isOpen];
					
					[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
				else
                    {
					[cell setOpen];
					dropDown4Open = [cell isOpen];
					
					[tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
					[tableView scrollToRowAtIndexPath:path6 atScrollPosition:UITableViewScrollPositionBottom animated:YES];					
                    }
				
				break;
                }   
                default:
                {
				dropDown4 = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
				
				NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:[indexPath section]];
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:path];
				
				[[cell textLabel] setText:dropDown4];
				
				NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
				AppDelegate.ShowLineForEveryLine = [[dropDown4 stringByTrimmingCharactersInSet:nonDigits ] intValue];
				if(AppDelegate.ShowLineForEveryLine == 0)
					AppDelegate.ShowLineForEveryLine=1;
                    // close the dropdown cell
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[path row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[path row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[path row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[path row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[path row]+5 inSection:[indexPath section]];
				NSIndexPath *path5 = [NSIndexPath indexPathForRow:[path row]+6 inSection:[indexPath section]];
				NSIndexPath *path6 = [NSIndexPath indexPathForRow:[path row]+7 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2,path3, path4, path5, path6,nil];
				
				[cell setClosed];
				dropDown4Open = [cell isOpen];
				
				[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
				
				break;
                }
            }
            
            break;
        }
        case 4: { // Show cell names as
            
            switch ([indexPath row]) {
                case 0:
                {
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[indexPath row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[indexPath row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[indexPath row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[indexPath row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[indexPath row]+5 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2, path3, path4, nil];
				
				if ([cell isOpen])
                    {
					[cell setClosed];
					dropDown5Open = [cell isOpen];
					
					[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
				else
                    {
					[cell setOpen];
					dropDown5Open = [cell isOpen];
					
					[tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
					[tableView scrollToRowAtIndexPath:path4 atScrollPosition:UITableViewScrollPositionBottom animated:YES];					
                    }
				
				break;
                }   
                default:
                {
				dropDown5 = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
				
				NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:[indexPath section]];
				DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:path];
				
				[[cell textLabel] setText:dropDown5];
				
                    // close the dropdown cell
				
				NSIndexPath *path0 = [NSIndexPath indexPathForRow:[path row]+1 inSection:[indexPath section]];
				NSIndexPath *path1 = [NSIndexPath indexPathForRow:[path row]+2 inSection:[indexPath section]];
				NSIndexPath *path2 = [NSIndexPath indexPathForRow:[path row]+3 inSection:[indexPath section]];
				NSIndexPath *path3 = [NSIndexPath indexPathForRow:[path row]+4 inSection:[indexPath section]];
				NSIndexPath *path4 = [NSIndexPath indexPathForRow:[path row]+5 inSection:[indexPath section]];
				
				NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1, path2, path3, path4, nil];
				
				[cell setClosed];
				dropDown5Open = [cell isOpen];
				
				[tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
				
				break;
                }
            }
            
            break;
        }
		case 5: // Login button
		{
		AppDelegate.loginController.isPushed = YES;
		[self.navigationController pushViewController:AppDelegate.loginController animated:YES];
		}
		break;
		case 6: // Server settings
		{
		[self.navigationController pushViewController:AppDelegate.serverSettings animated:YES];
		}
			break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
