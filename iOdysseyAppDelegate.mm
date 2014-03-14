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
@synthesize dataScopeStart, dataScopeEnd;
@synthesize ganttDisplaySelectedOnly;
@synthesize ganttDisplaySmallLarge;
@synthesize ganttFastDraw;
@synthesize clientSearchController;
@synthesize theNewBookingControlller;
@synthesize timeZone;
@synthesize calendar;

@synthesize NewBookingButton;

iOdysseyAppDelegate* AppDelegate;

-(void)SetDate:(NSDate*)date
{
	Date thisMorning = Date(date).StartOfDay();
	ganttviewcontroller.buttonWithDateLabel.title = thisMorning.FormatForGanttView(true);
	displayStart = thisMorning;
	displayEnd = displayStart.DaysAfter(GanttViewScope);
}

- (void)showOptionView:(id)sender
{
	
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	AppDelegate = self;	// setup global pointer to self

	NSLog(@"%@", [[UIDevice currentDevice] systemVersion]);
	
	// Set the application defaults. Theese will be overwritten, if the user changes the settings in the preferences panel.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"DEMO", @"License",
								 nil];
	
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	
	viewData = [[ViewData alloc] init];
	
	timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];//  [NSTimeZone systemTimeZone];
	calendar = [NSCalendar currentCalendar];
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
	
	ganttDisplaySelectedOnly = NO;
	ganttFastDraw = NO;
	
	if(IsIpad)
		{
		ganttDisplayWidth = 1024;
		ganttDisplayHeight = 768;
		}
	else
		{
		ganttDisplayWidth = 480;
		ganttDisplayHeight = 320;
		}
	ganttResourcesSizeY = 100;
	ganttBookingHeight = 20;//15;

	loginData = [[LoginData alloc] init];	// and request login data. Getting approved login data continues the login sequence
	
	[self LoadPreferences];
	
	DLog(@"B:%@, %@, %@, %@\n", AppDelegate.SettingsServer, AppDelegate.SettingsDatabase, AppDelegate.SettingsUsername, AppDelegate.SettingsPassword);
	NSString *server = [NSString stringWithFormat:@"http://%@/isql", AppDelegate.SettingsServer];
	self.client = [SqlClient clientWithServer:server Instance:@"isola.cloudapp.net" Database:AppDelegate.SettingsDatabase
									 Username: AppDelegate.SettingsUsername Password:AppDelegate.SettingsPassword];
	
	consumables = [[Consumables alloc] init];
	combinationDataController = [[CombinationDataController alloc] init];
	colorData = [[ColorData alloc] init];
	clientData = [[ ClientData alloc] init];
	projectData = [[ ProjectData alloc] init];
	folderData = [[ FolderData alloc] init];
	
//	theNewBookingControlller = [[NewBookingController alloc] init];
	
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

		for (UIView *subview in [self.window subviews])
				{
				// Only remove the subviews with tag is equal to 1
				if (subview.tag == 9999)
					{
					[subview removeFromSuperview];
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
		NSString *asd = [prefs stringForKey:@"loginData.loginName"];
		if(asd != nil)// if we have any preferences, we have all of them
			{
			cout << "LoadPreferences" << endl;
//			SettingsServer   = [prefs stringForKey:@"SettingsServer"]; 
//			SettingsDatabase = [prefs stringForKey:@"SettingsDatabase"]; 
//			SettingsUsername = [prefs stringForKey:@"SettingsUsername"]; 
//			SettingsPassword = [prefs stringForKey:@"SettingsPassword"]; 
			
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
//			SettingsServer = @"ody2012.dk";
//			SettingsDatabase = @"DEV2012";
			
			loginData.loginName=@"michaelAC";
			loginData.password=@"69AC";
			
			AppDelegate.DataScopeBack = 1;
			AppDelegate.DataScopeForward = 6;
			AppDelegate.GanttViewScope = 2;
			AppDelegate.ShowLineForEveryLine = 4;
//			AppDelegate.ganttBookingHeight = 15;
//			SelectedCombination = 33;	// ALL ShortCut
			AppDelegate.GanttSlotNamesStyle = (SlotNameStyle)1;
			}
		}

	SettingsUsername = @"IOSUSER";
	SettingsPassword = @"nice@aZure";
	
    NSString *license = [[NSUserDefaults standardUserDefaults] stringForKey:@"License number"];

    NSLog(@"License: %@\n", license);
    
    // License can be null
    
    if(license==NULL)    // first run?
        license=@"DEMO";

    // Check first letter to be "9"
    NSString * firstLetter = [license substringToIndex:1];
    
    BOOL res = [firstLetter isEqualToString:@"9"];
    
	AppDelegate.SettingsServer  = @"172.30.74.128";
	AppDelegate.SettingsDatabase  = @"TEST";

    if(res && [license length] == 8)
    {
        // get letters "1-5, use as PROD???? in database name
        // "Server=" + sqlServer + ";Database=" + database +"
        AppDelegate.SettingsDatabase = [NSString stringWithFormat:@"PROD%@", [license substringWithRange:NSMakeRange(1,4)]];
        AppDelegate.SettingsServer = @"nice02azure.net"; //isola.cloudapp.net
    }
    

    
    
	if([AppDelegate.SettingsServer length] == 0)
		AppDelegate.SettingsServer = @"ody2012.dk";
	if([AppDelegate.SettingsDatabase length] == 0)
		AppDelegate.SettingsDatabase = @"TST2012.dk";
	
	DLog(@"B:%@, %@, %@, %@\n", AppDelegate.SettingsServer, AppDelegate.SettingsDatabase, AppDelegate.SettingsUsername, AppDelegate.SettingsPassword);

	//	SettingsUsername = @"perry";
	//	SettingsPassword = @"eee3";
	
	if(AppDelegate.ShowLineForEveryLine == 0)
		AppDelegate.ShowLineForEveryLine = 4;	// safe
	AppDelegate.SettingsDisplayUnbookedResources = true;
}


-(void)SavePreferences
{
	
	if(AppDelegate.loginController.HasBeenLoggedInOK == NO)
		return;
	
	cout << "SavePreferences" << endl;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//	[prefs setObject:SettingsServer forKey:@"SettingsServer"];
//	[prefs setObject:SettingsDatabase forKey:@"SettingsDatabase"];
//	[prefs setObject:SettingsUsername forKey:@"SettingsUsername"];
//	[prefs setObject:SettingsPassword forKey:@"SettingsPassword"];
	
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

	[self LoadPreferences];
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
-(IBAction)GanttZoomOut
{
//	displayStart = displayStart.DaysAfter(1);
	displayEnd = displayEnd.DaysAfter(1);
	[ganttviewcontroller.gantt setNeedsDisplay];
}
-(IBAction)GanttZoomIn
{
//	displayStart = displayStart.DaysBefore(1);
	if(displayEnd.nstimeInterval() - displayStart.nstimeInterval() > 36*60*60)
		displayEnd = displayEnd.DaysBefore(1);
	[ganttviewcontroller.gantt setNeedsDisplay];
}


-(IBAction)SetGanttDisplaySelectedOnly:(id)sender
{
	UISegmentedControl *s=(UISegmentedControl *)sender;
	
	int selected = [s selectedSegmentIndex];
	
	ganttDisplaySelectedOnly = (bool)selected;

	bool AnyResourcesSelected=NO;
	for(Resource* res in AppDelegate->viewData.Resources)
		if(res.Selected == YES)
			{
			AnyResourcesSelected=YES;
			break;
			}
	
	if(AnyResourcesSelected == NO)
		{
		for(Resource* res in AppDelegate->viewData.Resources)
			if(res.RE_KEY == AppDelegate.loginData.Login.RE_KEY)
				{
				res.Selected = YES;
				break;
				}
		}
	
	if(ganttDisplaySelectedOnly == YES)
		AppDelegate.displayStartY=0;

	[self.ganttviewcontroller.gantt setNeedsDisplay];

	DLog(@"GanttDisplaySelectedOnly: %d", ganttDisplaySelectedOnly);
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

	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;
	[ganttviewcontroller.gantt.invisibleScrollView setContentOffset:CGPointMake(1024-RESOURCENAMEWIDTH,0) animated:NO];
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

	if(deviceOrientation == ORIENTATION_PORTRAIT)
		[ganttviewcontroller ShowMyBookings: NO];
	else
		{
		[AppDelegate.MyBookingsAndDrillDown willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
		[ganttviewcontroller.gantt Redraw];
		}
	
	/*		-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
		AppDelegate.MyBookingsAndDrillDown*/
}

@end
