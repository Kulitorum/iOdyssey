//
//  NewBookingController.h
//  iOdyssey
//
//  Created by Kulitorum on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GanttView.h"

#import "Date.h"
#import <vector>
#import "GanttViewController.h"
#import "SqlClient.h"

/*
 EXEC  [dbo].[BOOKING_CREATE]
 @CL_KEY = 9130,	// client
 @PR_KEY = 311704,	// Project
 @WO_KEY = 85291,	// // 
 @AC_KEY = 78,		//
 @FROM_TIME = N'2011-09-26 09:00',
 @TO_TIME = N'2011-09-26 19:00',
 @SITE_KEY = 9999,
 @KeyList = N'101,109'  -- RE_KEYS for booking slots
 */

@interface ResourceAndTime : NSObject
{
	int RE_KEY;
	NSString *RE_NAME;
	Date FROM_TIME;
	Date TO_TIME;
};

@property int RE_KEY;
@property (nonatomic) IBOutlet NSString *RE_NAME;
@property Date FROM_TIME;
@property Date TO_TIME;


@end

@interface NewBookingController : GanttViewController<UITextViewDelegate, SqlClientDelegate>
{
	int CL_KEY;
	int PR_KEY;
	int WO_KEY;				// Folder key (work order)
	int AC_KEY;
	int BO_KEY;
	UITextView *bookingRemarkView;
@public 
	NSMutableArray *BookedResources;
}

@property (nonatomic) IBOutlet UIButton *ClientButton;
@property (nonatomic) IBOutlet UIButton *ProjectButton;
@property (nonatomic) IBOutlet UIButton *FolderButton;
@property (nonatomic) IBOutlet UITextView *FolderRemarksTextView;
@property (nonatomic) IBOutlet UIBarButtonItem *confirmBookingButton;
@property (nonatomic) UITextView *bookingRemarkView;

-(IBAction) ShowClientPicker:(id)sender;
-(IBAction) ShowProjectPicker:(id)sender;
-(IBAction) ShowFolderPicker:(id)sender;

-(IBAction) ConfirmBooking:(id)sender;
-(IBAction) CancelBooking:(id)sender;

-(void) checkIfBookingIsReady;

-(void)CreateBookingInDataBase;
-(void)UserPickedClient:(NSNotification *)notification;
-(void)UserPickedProject:(NSNotification *)notification;
-(void)UserPickedFolder:(NSNotification *)notification;

@end
