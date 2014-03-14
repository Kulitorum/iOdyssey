//
//  PreferencesController.h
//  iOdyssey
//
//  Created by Michael Holm on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropDownCell.h"
#import "LoginController.h"
#import "ServerSettings.h"

	//SELECT * FROM booking_slot_status_code

@interface PreferencesController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
	UITableView *table;
/*
 case 0:	return @"Data Scope backwards"; break;//User name/password
 case 1:	return @"Data Scope forwards"; break;//User name/password
 case 2:	return @"View Scope"; break;// remember password
 case 3:	return @"Resource dividers"; break;// remember password
 case 4:	return @"Show slot names as"; break;// remember password
*/	
	
	NSString *dropDown1;
    NSString *dropDown2;
    NSString *dropDown3;
    NSString *dropDown4;
    NSString *dropDown5;
	
    BOOL dropDown1Open;
    BOOL dropDown2Open;
    BOOL dropDown3Open;
    BOOL dropDown4Open;
    BOOL dropDown5Open;
}

@property (nonatomic) IBOutlet UITableView *table;

@property int DataScopeBack;
@property int DataScopeForward;
@property int GanttViewScope;
@property int ShowLineForEveryLine;

-(IBAction) Return:(id)sender;

@end
