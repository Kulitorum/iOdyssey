//
//  iOdysseyAppDelegate.m
//  iOdyssey
//
//  Created by Michael Holm on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iOdysseyAppDelegate.h"
#import "GanttViewController.h"

/*

 TODO:
 
 Mark curent time on gantt chart
 Mark weekends on gantt chart
 Fix time-progress view on MyBookingsController
 
 
 */

@implementation iOdysseyAppDelegate

@synthesize window=_window;
@synthesize viewController;
@synthesize loginData;
@synthesize colorData;
@synthesize clientData;
@synthesize projectData;
@synthesize folderData;
@synthesize SettingsServer, SettingsDatabase, SettingsUsername, SettingsPassword;
@synthesize loginOK, HasCombinationData;
@synthesize ganttviewcontroller;
@synthesize deviceOrientation;
@synthesize combinationDataController;
@synthesize SelectedCombination;
@synthesize myBookingsController;
@synthesize bookingDetailController, loginController, preferencesController, MyBookingsAndDrillDown, serverSettings;
@synthesize signOffViewController;
@synthesize SettingsDisplayUnbookedResources;
@synthesize IsIpad;
@synthesize genericPopupTableViewController;
@synthesize lastViewedBookingKey;

@synthesize DataScopeBack;
@synthesize DataScopeForward;
@synthesize GanttViewScope;
@synthesize ShowLineForEveryLine;
@synthesize GanttSlotNamesStyle;
@synthesize formatter;
@synthesize displayStartY;
@synthesize viewData;				// Resources and Bookings
@synthesize displayStart;
@synthesize displayEnd;
@synthesize ganttBookingHeight;
@synthesize ganttDisplayWidth;
@synthesize ganttDisplayHeight;
@synthesize ganttResourcesSizeY;
@synthesize addCommentViewController;
@synthesize scheduler;
@synthesize client;
@synthesize consumables;
@synthesize selected_BO_KEY;
@synthesize splashView;
@synthesize splashViewController;
@synthesize viewDataController;
@synthesize dataScopeStart, dataScopeEnd;
@synthesize ganttDisplayStyle;
@synthesize ganttDisplaySelectedOnly;
@synthesize ganttDisplaySmallLarge;
@synthesize ganttFastDraw;
@synthesize clientSearchController;
@synthesize newBookingControlller;

@synthesize timeZone;
@synthesize calendar;

@synthesize NewBookingButton;

iOdysseyAppDelegate* AppDelegate;

-(void)SetDate:(NSDate*)date
{
	Date thisMorning = Date(date).StartOfDay();
	ganttviewcontroller.buttonWithDateLabel.title = thisMorning.FormatForGanttView(true);
	displayStart = thisMorning;//.HoursAfter(1);
	displayEnd = displayStart.DaysAfter(GanttViewScope);
}

- (void)showOptionView:(id)sender
{
	
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	AppDelegate = self;	// setup global pointer to self

	
	// Set the application defaults
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"ody2012.dk", @"ServerAddress",
								 @"DEV2012", @"DatabaseName",
								 nil];
	
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	
	timeZone = [[NSTimeZone timeZoneForSecondsFromGMT:0] retain];//  [NSTimeZone systemTimeZone];
	calendar = [[NSCalendar currentCalendar] retain];
	[calendar setTimeZone:AppDelegate.timeZone];
	formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZZ"; //2011-02-07 09:00:00 +0000
	[formatter setTimeZone:timeZone];
	displayStart=Date(@"2011-10-15 06:00:00 +0000");
	displayEnd  =Date(@"2011-10-16 00:00:00 +0000");
	
	NSLog(@"Start: %@", displayStart.FormatForSQLWithTime());
	NSLog(@"End: %@", displayEnd.FormatForSQLWithTime());
	
	DataRequestCounter = 0;
	loginController.isDisplayingModalVewController=NO;
	
	loginOK=NO;
	HasCombinationData = NO;

	// Set init values
    IsIpad = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone);

	
	displayStartY = 0;
	DataScopeBack=1;
	DataScopeForward=6;
	GanttViewScope=2;
	ShowLineForEveryLine=4;
	
	GanttSlotNamesStyle = ACTIVITYSTYLE;
	
	
	displayStartY = 0;
	
	ganttDisplayStyle=YES;	//24h default
	ganttDisplaySelectedOnly = NO;
	ganttFastDraw = NO;
	
	if(IsIpad)
		{
		ganttDisplayWidth = 768;
		ganttDisplayHeight = 1024;
		}
	else
		{
		ganttDisplayWidth = 340;
		ganttDisplayHeight = 340;
		}
	ganttResourcesSizeY = 100;
	ganttBookingHeight = 20;//15;

	loginData = [[LoginData alloc] init];	// and request login data. Getting approved login data continues the login sequence
	
	[self LoadPreferences];
	
	DLog(@"B:%@, %@, %@, %@\n", AppDelegate.SettingsServer, AppDelegate.SettingsDatabase, AppDelegate.SettingsUsername, AppDelegate.SettingsPassword);
	NSString *server = [NSString stringWithFormat:@"http://%@/isql", AppDelegate.SettingsServer];
	self.client = [SqlClient clientWithServer:server Instance:@"" Database:AppDelegate.SettingsDatabase
									 Username: AppDelegate.SettingsUsername Password:AppDelegate.SettingsPassword];
	
	consumables = [[Consumables alloc] init];
	combinationDataController = [[CombinationDataController alloc] init];
	colorData = [[ColorData alloc] init];
	clientData = [[ ClientData alloc] init];
	projectData = [[ ProjectData alloc] init];
	folderData = [[ FolderData alloc] init];
	
//	newBookingControlller = [[NewBookingController alloc] init];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	
	switch([[UIApplication sharedApplication] statusBarOrientation])
	{
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			deviceOrientation = ORIENTATION_PORTRAIT;
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		default:
			deviceOrientation = ORIENTATION_LANDSCAPE;
			break;
	}
	
	[self SetDate:[NSDate date]];
	
	AppDelegate.MyBookingsAndDrillDown.activityIndicator.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
	AppDelegate.ganttviewcontroller.activityIndicator.transform = CGAffineTransformMakeScale(1.5f, 1.5f);

	
	[ganttviewcontroller ResizeToolbar];
	self.window.rootViewController = self.ganttviewcontroller;
	
	[self.window addSubview:ganttviewcontroller.view]; // gantt and mybookings
	[self.window addSubview:splashView];		  // splash
	[self.window makeKeyAndVisible];
	viewDataController = [[ViewDataController alloc] init];
	scheduler = [[Scheduler alloc] init];
	[self RequestNextDataType];
	    return YES;
}

-(bool)isDoneGettingInitData
{
	if(DataRequestCounter > 7)
		return YES;
	return NO;
}

-(bool) RequestNextDataType
{
	if(DataRequestCounter > 7)
		return NO;

	cout << "DataRequestCounter " << DataRequestCounter << endl;
	
	switch(DataRequestCounter)
	{
		case 0:		[loginData RequestLoginData]; break;
		case 1:		[combinationDataController RequestCombinationData]; break;
		case 2:		[colorData RequestColorData]; break;
		case 3:		[colorData RequestColorData2]; break;
		case 4:		[ganttviewcontroller.gantt RequestResourceData]; break;
		case 5:		[ganttviewcontroller RequestBookingData]; break;
		case 6:		[clientData RequestClientData];		break;
		case 7:
			clientSearchController = [[SearchableUITableViewController alloc] init];
			[clientSearchController initData];
			[viewDataController start];

		for (UIView *subview in [self.window subviews])
				{
				// Only remove the subviews with tag is equal to 1
				if (subview.tag == 9999)
					{
					[subview removeFromSuperview];
					[subview release];
					break;
					}
				}
		if(deviceOrientation == ORIENTATION_PORTRAIT)
			[ganttviewcontroller ShowMyBookings: NO];
		[MyBookingsAndDrillDown.activityIndicator stopAnimating];
		[ganttviewcontroller.activityIndicator stopAnimating];
		[MyBookingsAndDrillDown.myBookingsController RefreshView];
		[ganttviewcontroller.gantt Redraw];
		break;
		default:
			cout << "Done requesting init data" << endl;
			break;
	}

	[splashView.progressView setProgress:(float)DataRequestCounter/7.0f];
	
	DataRequestCounter++;
	return YES;
}

-(void)LoadPreferences
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if(prefs)
		{
		NSString *asd = [prefs stringForKey:@"SettingsServer"];
		if(asd != nil)// if we have any preferences, we have all of them
			{
			cout << "LoadPreferences" << endl;
			SettingsServer   = [prefs stringForKey:@"SettingsServer"]; 
			SettingsDatabase = [prefs stringForKey:@"SettingsDatabase"]; 
			SettingsUsername = [prefs stringForKey:@"SettingsUsername"]; 
			SettingsPassword = [prefs stringForKey:@"SettingsPassword"]; 
			
			loginData.loginName = [prefs stringForKey:@"loginData.loginName"]; 
			loginData.password = [prefs stringForKey:@"loginData.password"]; 
			
			AppDelegate.DataScopeBack = [prefs integerForKey:@"DataScopeBack"];
			AppDelegate.DataScopeForward = [prefs integerForKey:@"DataScopeForward"];
			AppDelegate.GanttViewScope = [prefs integerForKey:@"GanttViewScope"];
			AppDelegate.ShowLineForEveryLine = [prefs integerForKey:@"ShowLineForEveryLine"];
//			AppDelegate.ganttBookingHeight = [prefs integerForKey:@"ganttBookingHeight"];
			
			SelectedCombination =  [prefs integerForKey:@"SelectedCombination"];
			AppDelegate.GanttSlotNamesStyle = (SlotNameStyle)[prefs integerForKey:@"GanttSlotNamesStyle"];
			}
		else
			{
			SettingsServer = @"ody2012.dk";
			SettingsDatabase = @"DEV2012";
			SettingsUsername = @"mh2012";
			SettingsPassword = @"iphone";
			
			loginData.loginName=@"michaelh";
			loginData.password=@"prince";
			
			AppDelegate.DataScopeBack = 1;
			AppDelegate.DataScopeForward = 6;
			AppDelegate.GanttViewScope = 2;
			AppDelegate.ShowLineForEveryLine = 4;
//			AppDelegate.ganttBookingHeight = 15;
			SelectedCombination = 33;	// ALL ShortCut
			AppDelegate.GanttSlotNamesStyle = (SlotNameStyle)1;
			}
		}

	
	// Get user preference
	{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ServerAddress = [defaults stringForKey:@"ServerAddress"];
	NSString *DatabaseName = [defaults stringForKey:@"DatabaseName"];

	//	DLog(@"B:%@, %@, %@, %@\n", AppDelegate.SettingsServer, AppDelegate.SettingsDatabase, AppDelegate.SettingsUsername, AppDelegate.SettingsPassword);

	
	SettingsServer = ServerAddress;
	SettingsDatabase = DatabaseName;
	
//	B:(null), DEV2012, demo, (null)
	
	
	}
	
	
	//	SettingsUsername = @"perry";
	//	SettingsPassword = @"eee3";
	
	if(AppDelegate.ShowLineForEveryLine == 0)
		AppDelegate.ShowLineForEveryLine = 4;	// safe
	if(SelectedCombination == 0)
		SelectedCombination = 33;
	AppDelegate.SettingsDisplayUnbookedResources = true;
}


-(void)SavePreferences
{
	
	if(AppDelegate.loginController.HasBeenLoggedInOK == NO)
		return;
	
	cout << "SavePreferences" << endl;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:SettingsServer forKey:@"SettingsServer"];
	[prefs setObject:SettingsDatabase forKey:@"SettingsDatabase"];
	[prefs setObject:SettingsUsername forKey:@"SettingsUsername"];
	[prefs setObject:SettingsPassword forKey:@"SettingsPassword"];
	
	[prefs setObject:loginData.loginName forKey:@"loginData.loginName"];
	[prefs setObject:loginData.password forKey:@"loginData.password"];
	
	[prefs setInteger:AppDelegate.DataScopeBack forKey:@"DataScopeBack"];
	[prefs setInteger:AppDelegate.DataScopeForward forKey:@"DataScopeForward"];
	[prefs setInteger:AppDelegate.GanttViewScope forKey:@"GanttViewScope"];
	[prefs setInteger:AppDelegate.ShowLineForEveryLine forKey:@"ShowLineForEveryLine"];
//	[prefs setInteger:AppDelegate.ganttBookingHeight forKey:@"ganttBookingHeight"];
	[prefs setInteger:SelectedCombination forKey:@"SelectedCombination"];
	[prefs setInteger:AppDelegate.GanttSlotNamesStyle forKey:@"GanttSlotNamesStyle"];
	
	[prefs synchronize];
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self SavePreferences];
	
	//	[UIApplication setKeepAliveTimeout:handler:]
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self SavePreferences];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
	[loginData release];
	[ColorData release];
    [viewController release];
	[client release];
    [_window release];
	[formatter release];
    [super dealloc];
}

-(void)SetGanttFastDraw:(bool)state
{
	ganttFastDraw = state;
	[self.ganttviewcontroller.gantt setNeedsDisplay];
}

-(IBAction)GanttNextDay
{
	displayStart = displayStart.DaysAfter(1);
	displayEnd = displayEnd.DaysAfter(1);
	[ganttviewcontroller.gantt setNeedsDisplay];
}
-(IBAction)GanttPreviousDayDay
{
	displayStart = displayStart.DaysBefore(1);
	displayEnd = displayEnd.DaysBefore(1);
	[ganttviewcontroller.gantt setNeedsDisplay];
}


-(IBAction)SetGanttDisplaySelectedOnly:(id)sender
{
	UISegmentedControl *s=(UISegmentedControl *)sender;
	
	int selected = [s selectedSegmentIndex];
	
	ganttDisplaySelectedOnly = (bool)selected;

	bool AnyResourcesSelected=NO;
    for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)// for all resources
		if(AppDelegate->viewData.Resources[i].Selected == YES)
			{
			AnyResourcesSelected=YES;
			break;
			}
	
	if(AnyResourcesSelected == NO)
		{
		for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)// for all resources
			if(AppDelegate->viewData.Resources[i].RE_KEY == AppDelegate.loginData.Login.RE_KEY)
				{
				AppDelegate->viewData.Resources[i].Selected = YES;
				break;
				}
		}
	
	if(ganttDisplaySelectedOnly == YES)
		AppDelegate.displayStartY=0;

	[self.ganttviewcontroller.gantt setNeedsDisplay];

	DLog(@"GanttDisplaySelectedOnly: %d", ganttDisplaySelectedOnly);
}

-(IBAction)SetGanttDisplayStyle:(id)sender
{
	UISegmentedControl *s=(UISegmentedControl *)sender;
	int selected = [s selectedSegmentIndex];
	ganttDisplayStyle = (bool)selected;
	[self.ganttviewcontroller.gantt setNeedsDisplay];
	DLog(@"ganttDisplayStyle: %d", ganttDisplayStyle);
}
-(void)SetGanttDisplaySmallLarge:(id)sender
{
	UISegmentedControl *s=(UISegmentedControl *)sender;
	int selected = [s selectedSegmentIndex];
	ganttDisplaySmallLarge = (bool)selected;
	if(ganttDisplaySmallLarge)
		AppDelegate.displayStartY=0;
	[self.ganttviewcontroller.gantt setNeedsDisplay];
	DLog(@"ganttDisplaySmallLarge: %d", ganttDisplaySmallLarge);
}

-(IBAction)textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

- (void) didRotate:(NSNotification *)notification
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if(UIInterfaceOrientationIsPortrait(orientation))
		deviceOrientation = ORIENTATION_PORTRAIT;
	else if(UIInterfaceOrientationIsLandscape(orientation))
		deviceOrientation = ORIENTATION_LANDSCAPE;
}

@end
