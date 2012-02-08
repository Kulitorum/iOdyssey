//
//  iOdysseyAppDelegate.h
//  iOdyssey
//
//  Created by Michael Holm on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#pragma once

#import <UIKit/UIKit.h>
#import "ViewData.h"
#import "GanttViewController.h"
#import "MyBookingsController.h"
#import "LoginData.h"
#import "CombinationDataController.h"
#import "ColorData.h"
#import "AddCommentViewController.h"
#import "SqlClient.h"
#import "Scheduler.h"
#import "Consumables.h"
#import "SplashView.h"
#import "SplashViewController.h"
#import "SignOffViewController.h"
#import "SearchableUITableViewController.h"
#import "NewBookingController.h"
#import "ClientData.h"
#import "ProjectData.h"
#import "FolderData.h"
#import "GenericPopupTableViewController.h"
#import "NavController.h"



//#define ALLOW_NO_PROJECT_AND_FOLDER




enum SlotNameStyle{BOOKINGNAMESTYLE, CLIENTSTYLE, PROJECTSTYLE, ACTIVITYSTYLE, BOOKINGIDSTYLE, UNKNOWNSTYLE};
enum ORIENTATION{ORIENTATION_LANDSCAPE, ORIENTATION_PORTRAIT, ORIENTATION_UNKNOWN};

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);



@interface iOdysseyAppDelegate : NSObject <UIApplicationDelegate> 
{
@public
    UIWindow *window;
	LoginData *loginData;	// instance of loginData
	ColorData *colorData;	// instance of loginData
	ClientData *clientData;
	ProjectData *projectData;
	FolderData *folderData;
	CombinationDataController *combinationDataController;
	GanttViewController *ganttviewcontroller;
	AddCommentViewController *addCommentViewController;
    PreferencesController* preferencesController;
    BookingDetailController *bookingDetailController;
    NavController *MyBookingsAndDrillDown;
	Scheduler *scheduler;
	Consumables *consumables;
	SplashViewController *splashViewController;
	SignOffViewController *signOffViewController;
	NewBookingController *theNewBookingControlller;
	GenericPopupTableViewController *genericPopupTableViewController;
	
	SearchableUITableViewController *clientSearchController;
	
	SplashView *splashView;
	
    Date displayStart;
    Date displayEnd;
	float displayStartY;			// The first Y coord of the gantt chart
	
    float ganttDisplayWidth;		// size of gantt window
	float ganttDisplayHeight;		// size of gantt window
	float ganttResourcesSizeY;		// Total height of the gantt view, needed for scroll-stop.
	float ganttBookingHeight;		// Height of each booking
    ViewData *viewData;				// Resources and Bookings
    CGPoint pan;					// Click point for panning
    NSDateFormatter *formatter;		// formatter
	NSCalendar* calendar;

	bool SettingsDisplayUnbookedResources;
	bool IsIpad;
	int lastViewedBookingKey;
	
	int DataScopeBack;
	int DataScopeForward;
	int GanttViewScope;
	int ShowLineForEveryLine;
	SlotNameStyle GanttSlotNamesStyle;
	
	NSString *SettingsServer;
	NSString *SettingsDatabase;
	NSString *SettingsUsername;
	NSString *SettingsPassword;
	bool loginOK;
	bool HasCombinationData;
	
	int SelectedCombination;
	
	bool ganttDisplaySmallLarge; // 0=small, 1=large
	bool ganttDisplaySelectedOnly; // 0=8h, 1=24h
	bool ganttFastDraw;
	
	ORIENTATION deviceOrientation;
    
	int DataRequestCounter;
	NSTimeZone *timeZone;

    int selected_BO_KEY;
	UIBarButtonItem *NewBookingButton;
}

@property (nonatomic, retain) SqlClient *client;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;
@property (nonatomic, retain) IBOutlet GanttViewController *ganttviewcontroller;
@property (nonatomic, retain) IBOutlet MyBookingsController *myBookingsController;
@property (nonatomic, retain) IBOutlet AddCommentViewController *addCommentViewController;
@property (nonatomic, retain) IBOutlet SplashView *splashView;
@property (nonatomic, retain) IBOutlet SplashViewController *splashViewController;
@property (nonatomic, retain) IBOutlet SignOffViewController *signOffViewController;
@property (nonatomic, retain) IBOutlet SearchableUITableViewController *clientSearchController;
@property (nonatomic, retain) IBOutlet NewBookingController *theNewBookingControlller;
@property (nonatomic, retain) IBOutlet NavController *MyBookingsAndDrillDown;
@property (nonatomic, retain) IBOutlet BookingDetailController *bookingDetailController;
@property (nonatomic, retain) IBOutlet LoginController *loginController;
@property (nonatomic, retain) IBOutlet PreferencesController* preferencesController;
@property (nonatomic, retain) IBOutlet ServerSettings* serverSettings;
@property (nonatomic, retain) IBOutlet GenericPopupTableViewController *genericPopupTableViewController;
@property (nonatomic, retain) IBOutlet 	UIBarButtonItem *NewBookingButton;
@property (nonatomic, retain) NSTimeZone *timeZone;
@property (nonatomic, retain) NSCalendar *calendar;

@property (nonatomic, retain) Consumables *consumables;

@property (nonatomic, retain) LoginData *loginData;
@property (nonatomic, retain) ColorData *colorData;
@property (nonatomic, retain) ClientData *clientData;
@property (nonatomic, retain) ProjectData *projectData;
@property (nonatomic, retain) FolderData *folderData;
@property (nonatomic, retain) NSString *SettingsServer;
@property (nonatomic, retain) NSString *SettingsDatabase;
@property (nonatomic, retain) NSString *SettingsUsername;
@property (nonatomic, retain) NSString *SettingsPassword;

@property (nonatomic, retain) Scheduler *scheduler;

@property (nonatomic, assign) int lastViewedBookingKey;

@property bool loginOK;
@property bool HasCombinationData;

@property float ganttResourcesSizeY;		// Total height of the gantt view, needed for scroll-stop.
@property float ganttBookingHeight;		// Height of each booking

@property float ganttDisplayWidth;
@property float ganttDisplayHeight;

@property float displayStartY;

@property (nonatomic, retain) ViewData *viewData;				// Resources and Bookings
@property Date displayStart;
@property Date displayEnd;
@property Date dataScopeStart;
@property Date dataScopeEnd;
@property (nonatomic, retain) NSDateFormatter *formatter;		// formatter

@property bool ganttDisplaySelectedOnly;
@property bool ganttDisplaySmallLarge;
@property bool ganttFastDraw;

@property (nonatomic, retain) IBOutlet CombinationDataController *combinationDataController;
@property ORIENTATION deviceOrientation;

@property bool SettingsDisplayUnbookedResources;
@property bool IsIpad;

@property int DataScopeBack;
@property int DataScopeForward;
@property int GanttViewScope;
@property int ShowLineForEveryLine;
@property SlotNameStyle GanttSlotNamesStyle;

@property int SelectedCombination;
@property int selected_BO_KEY;

-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)SetGanttDisplaySelectedOnly:(id)sender;
-(IBAction)SetGanttDisplaySmallLarge:(id)sender;
-(IBAction)GanttNextDay;
-(IBAction)GanttPreviousDayDay;
-(IBAction)GanttZoomOut;
-(IBAction)GanttZoomIn;
-(void)SetGanttFastDraw:(bool)state;

-(IBAction)showOptionView:(id)sender;

-(void)SavePreferences;
-(void)LoadPreferences;
-(void)didRotate:(NSNotification *)notification;
-(void)SetDate:(NSDate*)date;
-(bool)RequestNextDataType;
-(bool)isDoneGettingInitData;

@end

extern iOdysseyAppDelegate* AppDelegate;
