//
//  iSqlExampleViewController.h
//  iSqlExample
//
//  Created by Robert Chipperfield on 13/01/2011.
//  Copyright 2011 Red Gate Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SqlClient.h"
#import "GanttView.h"
#import "ServerSettings.h"
#import "MyBookingsController.h"
#import "PreferencesController.h"
#import "NavController.h"

@interface GanttViewController : UIViewController<SqlClientDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
	UIActivityIndicatorView *activityIndicator;
	NSDate *pickedDate;
	UIBarButtonItem *buttonWithDateLabel;
	UIBarButtonItem *buttonWithCombinationLabel;
	UIToolbar *GanttToolBar;
	bool isCreatingNewBooking;
}
@property (nonatomic, retain) IBOutlet GanttView *gantt;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet NSDate *pickedDate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonWithDateLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonWithCombinationLabel;
@property (nonatomic, retain) IBOutlet UIToolbar *GanttToolBar;

@property bool isCreatingNewBooking;

-(IBAction) StartNewBooking;
-(IBAction) ShowClientsViewController;
-(IBAction) ShowMyBookings:(bool)animated;
-(IBAction) RequestBookingData;
-(IBAction) Home:(id)sender;
- (IBAction)callDP:(id)sender;
- (IBAction) dismissDatePicker:(id)sender;
-(void) SetCombinationButtonLabel;
-(IBAction)ShowCombinationPopup:(id)sender;
-(void) RefreshBookings;
-(void)ResizeToolbar;
//-(void)handleSwipeGesture:(UIGestureRecognizer *)sender;
-(void)handlelongPressGesture:(UIGestureRecognizer *)sender;


@end

