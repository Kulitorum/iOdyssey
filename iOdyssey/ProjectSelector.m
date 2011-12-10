//
//  ProjectSelector.m
//  iOdyssey
//
//  Created by Kulitorum on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProjectSelector.h"
#import "iOdysseyAppDelegate.h"
#import "UILabelWithTopbarBG.h"

@implementation ProjectSelector

- (UIView *)inputView
{
	return AppDelegate.genericPopupTableViewController.view;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePopup:) name:@"userPickedProject" object:nil];

	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 520)];
	
	UILabel *topLabel = [[UILabelWithTopbarBG alloc] initWithFrame:CGRectMake(0, 0, 1024, 45)];
	topLabel.text = @"Pick project for new booking";
	topLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 14.0];
	topLabel.textColor = [UIColor whiteColor];
	topLabel.textAlignment = UITextAlignmentCenter;
	
	UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 1024, 550)];
	
	table.dataSource = AppDelegate.projectData;
	table.delegate = AppDelegate.projectData;
	
	[view addSubview:topLabel];
	[view addSubview:table];
	
	AppDelegate.genericPopupTableViewController.tableView = table;
	[topLabel release];
	[table release];
	
	AppDelegate.genericPopupTableViewController.view = view;

    [self becomeFirstResponder];	// Show GenericPopupController
}

-(void)closePopup:(NSNotification *)notification
{
	[self resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dealloc
{
    [super dealloc];
}

@end
