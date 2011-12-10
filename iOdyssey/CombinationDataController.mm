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
#include <iostream>
#import "iOdysseyAppDelegate.h"

	//#include "iOdysseyAppDelegate.h"

#define UIAppDelegate \
((MyAppDelegate *)[UIApplication sharedApplication].delegate)

using namespace std;

@implementation CombinationDataController

@synthesize views;

- (void)dealloc
{
    [super dealloc];
}

-(id) init
{
	[super init];
	if(self)
		{
		}
	return self;
}

#pragma mark - View lifecycle

-(NSString *)pickerView : (UIPickerView *)pickerView titleForRow : (NSInteger)row forComponent : (NSInteger)component
{
	return views[row].RV_NAME;
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
    
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
            while ([resultSet moveNext])
				{
				NSString *theName = [[resultSet getString:3] retain];
					//				DLog(@"Combination: %@ ID:%d\n", theName, [resultSet getInteger:0] );
                views.push_back( Combination([resultSet getInteger:0], [theName retain]) );
                cout << ".";
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
    return views.size();
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	cout << "Manager.SelectedCombination:" << views[row].RV_KEY << endl;
	AppDelegate.SelectedCombination = views[row].RV_KEY;
}
@end
