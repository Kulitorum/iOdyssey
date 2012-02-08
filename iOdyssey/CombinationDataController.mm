//
//  CombinationDataController.m
//  iOdyssey
//
//  Created by Michael Holm on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "CombinationDataController.h"
#import "iOdysseyAppDelegate.h"

	//#include "iOdysseyAppDelegate.h"

#define UIAppDelegate \
((MyAppDelegate *)[UIApplication sharedApplication].delegate)

using namespace std;

@implementation Combination


-(id)initWithData:(int)nr name:(NSString*) name
{
	self = [super init];
	if(self)
		{
		RV_KEY = nr;
		RV_NAME = [name retain];
		}
	return self;
}

-(void) dealloc
{
	[RV_NAME release];
}

@synthesize RV_KEY, RV_NAME;

@end


@implementation CombinationDataController

@synthesize views;

- (void)dealloc
{
	[views release];
	views=nil;
    [super dealloc];
}

-(id) init
{
	self = [super init];
	if(self)
		{
		}
	return self;
}

#pragma mark - View lifecycle

-(NSString *)pickerView : (UIPickerView *)pickerView titleForRow : (NSInteger)row forComponent : (NSInteger)component
{
	return ((Combination*)[views objectAtIndex:row]).RV_NAME;
} 

-(void)RequestCombinationData
{
    cout << "Request combination Data" << endl;
	//	[AppDelegate.client executeQuery:@"SELECT * FROM dbo.RESOURCE_VIEW;" withDelegate:self];

	NSString *request = [NSString stringWithFormat:@"SELECT * FROM dbo.RESOURCE_VIEW WHERE SITE_KEY = %d ORDER BY RV_NAME",AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return YES;
	return NO;
}

/*
 R V_KEY |VERSION |USER_KEY |RV_NAME |RC_KEY |DP_KEY |SORT_ORDER |SELECT_ALL_ON_OPEN |CLEAR_SELECTION_ON_OPEN |VIEW_TYPE |IS_PROTECTED |
 --------
 4 | <null> | <null> | Mødelokale | <null> | <null> | 12 | 0 | -1 | <null> | <null> | 
 7 | <null> | <null> | Administration | <null> | <null> | 11 | 0 | -1 | <null> | <null> | 
 8 | <null> | <null> | Udskydning | <null> | <null> | 6 | 0 | -1 | <null> | <null> | 
 9 | <null> | <null> | Mastering | <null> | <null> | 7 | 0 | -1 | <null> | <null> | */

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
    cout << "Got Combination Data, processing" << endl;
    
	if(views == nil)
		views = [[NSMutableArray alloc] init];
	else
		[views removeAllObjects];
	
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
            while ([resultSet moveNext])
				{
				Combination *tmp = [[Combination alloc] initWithData:[resultSet getInteger:0] name:[resultSet getString:3]];
				[views addObject:tmp];
				[tmp release];
				}
			}
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];   
		}
    
	[AppDelegate RequestNextDataType];
	[AppDelegate.ganttviewcontroller SetCombinationButtonLabel];
    cout << "Done processing Combination data" << endl;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [views count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	AppDelegate.SelectedCombination = ((Combination*)[views objectAtIndex:row]).RV_KEY;
}


@end
