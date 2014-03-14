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

@interface GanttViewController : UIViewController<SqlClientDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
{
	UIActivityIndicatorView *activityIndicator;
	NSDate *pickedDate;
	UIBarButtonItem *buttonWithDateLabel;
	UIBarButtonItem *buttonWithCombinationLabel;
	UIToolbar *GanttToolBar;
	bool isCreatingNewBooking;
@public
	bool isShowingMyBookings;
	bool isShowingBookingDetailView;
}

@property (nonatomic) IBOutlet GanttView *gantt;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic) IBOutlet NSDate *pickedDate;
@property (nonatomic) IBOutlet UIBarButtonItem *buttonWithDateLabel;
@property (nonatomic) IBOutlet UIBarButtonItem *buttonWithCombinationLabel;
@property (nonatomic) IBOutlet UIToolbar *GanttToolBar;

@property bool isCreatingNewBooking;

-(IBAction) RequestBookingData;
-(IBAction) StartNewBooking;
-(IBAction) ShowMyBookings:(bool)animated;
-(IBAction) Home:(id)sender;
- (IBAction)callDP:(id)sender;
- (IBAction) dismissDatePicker:(id)sender;
-(void) SetCombinationButtonLabel;
-(IBAction)ShowCombinationPopup:(id)sender;
-(IBAction) RefreshBookings;
-(void)ResizeToolbar;
//-(void)handleSwipeGesture:(UIGestureRecognizer *)sender;
-(void)handlelongPressGesture:(UIGestureRecognizer *)sender;


@end

