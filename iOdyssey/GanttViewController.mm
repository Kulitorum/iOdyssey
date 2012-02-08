//
//  iSqlExampleViewController.m
//  iSqlExample
//
//  Created by Robert Chipperfield on 13/01/2011.
//  Copyright 2011 Red Gate Software. All rights reserved.
//

#import "GanttViewController.h"

#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "iOdysseyAppDelegate.h"

#include <iostream>

using namespace std;

float initialDistance;
CGPoint SingleTouchPoint;
CGPoint FirstSingleTouchPoint;
bool isDoubleTouch;

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

@implementation GanttViewController
@synthesize gantt, activityIndicator, toolBar, pickedDate, buttonWithDateLabel, buttonWithCombinationLabel, GanttToolBar;
@synthesize isCreatingNewBooking;


enum DragMode{DragModeMoveStart, DragModeMoveEnd, DragModeMoveBooking, NotDragging};

DragMode BookingDragMode = NotDragging;	// NO=start, YES=end
ResourceAndTime *lastPickedResource;

-(id) initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	if (self)
		{
		}
	return self;
}

- (void)changeDate:(UIDatePicker *)sender
{
	pickedDate=[sender.date retain];
}

- (void)removeViews:(id)object
{
	[[self.view viewWithTag:9] removeFromSuperview];
	[[self.view viewWithTag:10] removeFromSuperview];
	[[self.view viewWithTag:11] removeFromSuperview];
}

-(void)dismissCombinationPicker:(id)sender
{
	[AppDelegate.MyBookingsAndDrillDown.activityIndicator startAnimating];
	[activityIndicator startAnimating];
	CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 480, 44);
	CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 480, 216);
	[UIView beginAnimations:@"MoveOut" context:nil];
	[self.view viewWithTag:9].alpha = 0;
	[self.view viewWithTag:10].frame = datePickerTargetFrame;
	[self.view viewWithTag:11].frame = toolbarTargetFrame;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeViews:)];
	[UIView commitAnimations];
	[self SetCombinationButtonLabel];
	[self.gantt RequestResourceData];

	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;
	[gantt.invisibleScrollView setContentOffset:CGPointMake(1024-RESOURCENAMEWIDTH,0) animated:NO];
}

-(void) SetCombinationButtonLabel
{
	int selected=AppDelegate.SelectedCombination;
	// find selected
	
	NSEnumerator * enumerator = [AppDelegate.combinationDataController.views objectEnumerator];
	Combination* element;
	
	while(element = [enumerator nextObject])
		{
		if(element.RV_KEY == selected)
			{
			buttonWithCombinationLabel.title = element.RV_NAME;
			break;
			}
		}
}


- (void)dismissDatePicker:(id)sender
{
	CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 480, 44);
	CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 480, 216);
	[UIView beginAnimations:@"MoveOut" context:nil];
	[self.view viewWithTag:9].alpha = 0;
	[self.view viewWithTag:10].frame = datePickerTargetFrame;
	[self.view viewWithTag:11].frame = toolbarTargetFrame;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeViews:)];
	[UIView commitAnimations];
	
	[AppDelegate SetDate:pickedDate];
	[self RequestBookingData];
}

-(void)gotoToday:(id)sender
{
	pickedDate = [NSDate date];
	[self dismissDatePicker:sender];
	[self RequestBookingData];
}

- (IBAction)callDP:(id)sender
{
	if ([self.view viewWithTag:9])
		{
		return;
		}
	CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, self.view.bounds.size.width, 44);
	CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, self.view.bounds.size.width, 216);
	
	UIView *darkView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	darkView.alpha = 0;
	darkView.backgroundColor = [UIColor blackColor];
	darkView.tag = 9;
	UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] autorelease];
	[darkView addGestureRecognizer:tapGesture];
	[self.view addSubview:darkView];
	
	UIDatePicker *datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)] autorelease];
	datePicker.datePickerMode=UIDatePickerModeDate;
	datePicker.tag = 10;
	[datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
	
	datePicker.date = AppDelegate.displayStart.nsdate();
	pickedDate=datePicker.date; // init value
	
	[self.view addSubview:datePicker];
	
	UIToolbar *DatetoolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)] autorelease];
	DatetoolBar.tag = 11;
	DatetoolBar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)] autorelease];
	
	UIBarButtonItem *button1 = [[[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self  action:@selector(gotoToday:)] autorelease];
	[DatetoolBar setItems:[NSArray arrayWithObjects:spacer, button1, doneButton, nil]];
	[self.view addSubview:DatetoolBar];
	
	[UIView beginAnimations:@"MoveIn" context:nil];
	DatetoolBar.frame = toolbarTargetFrame;
	datePicker.frame = datePickerTargetFrame;
	darkView.alpha = 0.5;
	[UIView commitAnimations];
}

-(void)ResizeToolbar
{
	if(AppDelegate.IsIpad)
		[GanttToolBar setFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
	else
		[GanttToolBar setFrame:CGRectMake(0, self.view.bounds.size.height-30, self.view.bounds.size.width, 30)];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	pickedDate = [[NSDate alloc] init];
	isCreatingNewBooking = NO;

	/*
	 if ([UIView instancesRespondToSelector:@selector(addGestureRecognizer:)])
	 {
	 UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(navBarSwipeDetected:)];
	 swiper.direction = UISwipeGestureRecognizerDirectionRight;
	 swiper.numberOfTouchesRequired = 1;
	 [self.navigationController.navigationBar addGestureRecognizer:swiper];
	 swiper.direction = UISwipeGestureRecognizerDirectionLeft;
	 [self.navigationController.navigationBar addGestureRecognizer:swiper];
	 [swiper release];
	 }
*/	
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongPressGesture:)];
    longPressRecognizer.minimumPressDuration = 1.0;
    longPressRecognizer.numberOfTouchesRequired = 1;
    [self.gantt addGestureRecognizer:longPressRecognizer];
    [longPressRecognizer release];
    
/*	
	UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongPressGesture:)];
	swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
	[self.gantt addGestureRecognizer:swipeGesture];
    [swipeGesture release];
*/	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receiveTestNotification:) 
												 name:@"TestNotification"
											   object:nil];
}

/* Combination selection popup */
- (IBAction)ShowCombinationPopup:(id)sender
{
	CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, self.view.bounds.size.width, 44);
	CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, self.view.bounds.size.width, 216);
	
	UIView *darkView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	darkView.alpha = 0;
	darkView.backgroundColor = [UIColor blackColor];
	darkView.tag = 9;
	UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] autorelease];
	[darkView addGestureRecognizer:tapGesture];
	[self.view addSubview:darkView];
	
	UIPickerView *Picker = [[[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)] autorelease];
	Picker.dataSource = AppDelegate.combinationDataController;
	Picker.delegate = AppDelegate.combinationDataController;
	Picker.tag = 10;
	Picker.showsSelectionIndicator=YES;
	
	[self.view addSubview:Picker];
	
	UIToolbar *DatetoolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)] autorelease];
	DatetoolBar.tag = 11;
	DatetoolBar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissCombinationPicker:)] autorelease];
	[DatetoolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
	[self.view addSubview:DatetoolBar];
	
	[UIView beginAnimations:@"MoveIn" context:nil];
	DatetoolBar.frame = toolbarTargetFrame;
	Picker.frame = datePickerTargetFrame;
	darkView.alpha = 0.5;
	
	[UIView commitAnimations];
	
	int selected=AppDelegate.SelectedCombination;
	// find selected

	NSEnumerator * enumerator = [AppDelegate.combinationDataController.views objectEnumerator];
	Combination* element;

	while(element = [enumerator nextObject])
		{
		if(element.RV_KEY == selected)
			{
			[Picker selectRow: [AppDelegate.combinationDataController.views indexOfObject:element] inComponent:0 animated:NO];
			break;
			}
		}

}

-(IBAction) Home:(id)sender
{
	[AppDelegate.MyBookingsAndDrillDown.activityIndicator startAnimating];
	[activityIndicator startAnimating];
	[AppDelegate SetDate:[NSDate date]];
	[self RequestBookingData];
}

- (IBAction)RefreshBookings
{
	[activityIndicator startAnimating];
	[AppDelegate.MyBookingsAndDrillDown.activityIndicator startAnimating];
	[self RequestBookingData];
}

-(void) RequestBookingData
{
    cout << "Requesting booking data" << endl;
	
	/*	NSString *request = [NSString stringWithFormat:@"SELECT * FROM  vw_staff_schedule WHERE (RV_KEY = %d OR (RE_KEY = %d AND RV_KEY = 33)) AND FROM_TIME BETWEEN '%@' AND '%@' AND SITE_KEY = %d AND IS_CURRENT=1", AppDelegate.SelectedCombination, AppDelegate->loginData.Login.RE_KEY, AppDelegate.displayStart.DaysBefore(AppDelegate.DataScopeBack).FormatForSQL(), AppDelegate.displayEnd.DaysAfter(AppDelegate.DataScopeForward).FormatForSQL(), AppDelegate->loginData.Login.SITE_KEY];
	 */

	AppDelegate.dataScopeStart = AppDelegate.displayStart.DaysBefore(AppDelegate.DataScopeBack);
	AppDelegate.dataScopeEnd = AppDelegate.displayEnd.DaysAfter(AppDelegate.DataScopeForward);
	
	NSString *S = AppDelegate.dataScopeStart.FormatForSQL();
	NSString *E = AppDelegate.dataScopeEnd.FormatForSQL();
	
	NSString *request = [NSString stringWithFormat:@"SELECT * FROM  vw_staff_schedule WHERE (RV_KEY = %d OR RE_KEY = %d) AND ((FROM_TIME BETWEEN '%@' AND '%@') OR (TO_TIME BETWEEN '%@' AND '%@') OR (FROM_TIME <= '%@' AND TO_TIME >= '%@' )) AND SITE_KEY = %d",
						 AppDelegate.SelectedCombination,
						 AppDelegate->loginData.Login.RE_KEY,
						 S,
						 E,
						 S,
						 E,
						 S,
						 E,
						 AppDelegate->loginData.Login.SITE_KEY];
	
	DLog(@"%@", request);
	
	[AppDelegate.client executeQuery:request withDelegate:self];
}

bool BookingSortPredicate(Booking* d1, Booking* d2)
{
	float lengthd1 =  d1.TO_TIME.nstimeInterval() - d1.FROM_TIME.nstimeInterval();
	float lengthd2 =  d2.TO_TIME.nstimeInterval() - d2.FROM_TIME.nstimeInterval();
	return lengthd1 > lengthd2;
}


- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
    cout << "Got booking data, processing" << endl;
	
	//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
		[AppDelegate->viewData clearBookings];
		
		for (SqlResultSet *resultSet in query.resultSets)
			{
			/*
			NSMutableString* outputString = [[NSMutableString alloc] initWithCapacity:5000];
			for (int i = 0; i < resultSet.fieldCount; i++)
			 {
			 [outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
			 }
			 [outputString appendString:@"\r\n--------\r\n"];
			
			NSLog(@"%@", outputString);
			[outputString release];
			 */
			/*
			 unsigned char  ResourceP = [resultSet indexForField:@"Resource"];
			 Resource = [[resultSet getString:ResourceP compare:@"S"] UTF8String];
			 */
			NSInteger RE_KEY = [resultSet indexForField:@"RE_KEY"];
			NSInteger ResourceKey = [resultSet indexForField:@"Resource"];
			NSInteger STATUS = [resultSet indexForField:@"STATUS"];
			NSInteger PCODE = [resultSet indexForField:@"PCODE"];
			NSInteger MTYPE = [resultSet indexForField:@"MTYPE"];
			NSInteger BS_KEY = [resultSet indexForField:@"BS_KEY"];
			NSInteger FROM_TIME = [resultSet indexForField:@"FROM_TIME"];
			NSInteger TO_TIME = [resultSet indexForField:@"TO_TIME"];
			NSInteger BO_KEY = [resultSet indexForField:@"BO_KEY"];
			NSInteger FIRST_NAME = [resultSet indexForField:@"FIRST_NAME"];
			NSInteger LAST_NAME = [resultSet indexForField:@"LAST_NAME"];
			NSInteger NAME = [resultSet indexForField:@"NAME"];
			NSInteger BK_Remark = [resultSet indexForField:@"BK_Remark"];
			NSInteger Folder_name = [resultSet indexForField:@"Folder_name"];
			NSInteger Folder_remark = [resultSet indexForField:@"Folder_remark"];
			NSInteger TYPE = [resultSet indexForField:@"TYPE"];
			NSInteger CL_NAME = [resultSet indexForField:@"CL_NAME"];
			NSInteger ACTIVITY = [resultSet indexForField:@"ACTIVITY"];
			
			
			//Resource RE_KEY STATUS PCODE MTYPE BS_KEY FROM_TIME TO_TIME BO_KEY FIRST_NAME LAST_NAME NAME BK_Remark Folder_name Folder_remark TYPE CL_NAME
			
			while ([resultSet moveNext])
				{
				Booking *book = [[[Booking alloc] init] autorelease];
				book.BO_KEY = [resultSet getInteger:BO_KEY];

				book.RE_KEY = [ resultSet getInteger: RE_KEY ];
				book.Resource = [resultSet getString: ResourceKey];
				
				//book.STATUS
				NSString *status = [resultSet getString: STATUS];
				//				Dlog(@"Status:%@\n",status);
				if(status != nil && ([status isKindOfClass:[NSString class]] == YES))
					{
					if ([status compare:@"ROS"] == NSOrderedSame) book.STATUS=ROS;
					else if ([status compare:@"BKS"] == NSOrderedSame) book.STATUS=BKS;
					else if ([status compare:@"BK"] == NSOrderedSame) book.STATUS=BK;
					else if (([status compare:@"16"] == NSOrderedSame)) book.STATUS=A16;
					else if (([status compare:@"35"] == NSOrderedSame)) book.STATUS=A35;
					else if ([status compare:@"HL1"] == NSOrderedSame) book.STATUS=HL1;
					else if (([status compare:@"HL2"] == NSOrderedSame)) book.STATUS=HL2;
					else if (([status compare:@"IO"] == NSOrderedSame)) book.STATUS=IO;
					else if (([status compare:@"CNI"] == NSOrderedSame)) book.STATUS=CNI;
					else if (([status compare:@"CND"] == NSOrderedSame)) book.STATUS=CND;
					else if (([status compare:@"P01"] == NSOrderedSame)) book.STATUS=P01;
					else if (([status compare:@"N/A"] == NSOrderedSame)) book.STATUS=NA;
					else if (([status compare:@"MET"] == NSOrderedSame)) book.STATUS=MET;
					else if (([status compare:@"TRA"] == NSOrderedSame)) book.STATUS=TRA;
					else if (([status compare:@"SIP"] == NSOrderedSame)) book.STATUS=SIP;
					else if (([status compare:@"GRATIS"] == NSOrderedSame)) book.STATUS=GRATIS;
					else if (([status compare:@"INVOICED"] == NSOrderedSame)) book.STATUS=INVOICED;
					else book.STATUS = UNKNOWN;
					}
				else
					book.STATUS = ERROR;
				NSString *pco = [resultSet getString: PCODE];
				if(pco != nil && ([pco isKindOfClass:[NSString class]] == YES))
					{
					book.pcode=P_UNKNOWN;
					if ([pco compare:@"O"] == NSOrderedSame) book.pcode=P_OPEN;
					else if ([pco compare:@"F"] == NSOrderedSame) book.pcode=P_FINISHED;
					else if ([pco compare:@"A"] == NSOrderedSame) book.pcode=P_APPROVED;
					else if (([pco compare:@"P"] == NSOrderedSame)) book.pcode=P_PRECALC;
					else if (([pco compare:@"Q"] == NSOrderedSame)) book.pcode=P_PROFORMA;
					else if (([pco compare:@"I"] == NSOrderedSame)) book.pcode=P_INVOICED;
					else if (([pco compare:@"M"] == NSOrderedSame)) book.pcode=P_LOGGEDOUT;
					else if (([pco compare:@"G"] == NSOrderedSame)) book.pcode=P_GRATIS;
					else book.pcode = P_UNKNOWN;
					if(book.pcode == P_UNKNOWN)
						DLog(@"UNKNOWN PCODE: %@", pco);
					}
				else book.pcode = P_ERROR;
				
				book.MTYPE = [resultSet getInteger:MTYPE];
				
				book.FROM_TIME = Date([resultSet getDate:FROM_TIME]);
				book.TO_TIME = Date([resultSet getDate:TO_TIME]);
				
				book.FIRST_NAME = [resultSet getString:FIRST_NAME];
				book.ACTIVITY = [resultSet getString:ACTIVITY];
				book.LAST_NAME = [resultSet getString:LAST_NAME];
				book.NAME = [resultSet getString:NAME];
				book.BK_Remark = [resultSet getString:BK_Remark];
				book.Folder_name = [resultSet getString:Folder_name];
				book.Folder_remark = [resultSet getString:Folder_remark];
				book.TYPE = [resultSet getString:TYPE];
				book.BS_KEY = [resultSet getInteger:BS_KEY];
				book.CL_NAME = [resultSet getString:CL_NAME];
				[book checkIntegrity];
				[AppDelegate->viewData AddBooking:book LOGGEDIN_RESOURCE_ID: AppDelegate->loginData.Login.RE_KEY];    // Store booking in gantt chart
				}
			}
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];    [alert show];
			[alert release];   
		}
	// sort booking by length
	for(Resource* res in AppDelegate->viewData.Resources)
		[res sortBookingsByStartDate];
	
    cout << "Done processing " << [AppDelegate->viewData.Resources count] << " resources, deleting activityIndicator" << endl;
	
	if([AppDelegate RequestNextDataType] == NO) // start next data fetch
		{
		[AppDelegate.MyBookingsAndDrillDown.activityIndicator stopAnimating];
		[AppDelegate.ganttviewcontroller.activityIndicator stopAnimating];
		[self.gantt setNeedsDisplay];
		[AppDelegate.myBookingsController RefreshView];
		}
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[pickedDate release];
}
/*
 -(void) showAlertView:(NSTimer *)theTimer {
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birth of a star" message:@"Thou shalt not press thy screen." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];    [alert show];
 [alert release];   
 }
 
 //Start a timer for 2 seconds.
 NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showAlertView:) userInfo:nil repeats:NO];
 [timer retain];
 */

float distanceBetweenTwoPoints(CGPoint fromPoint, CGPoint toPoint)
{
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

float distanceBetweenTwoPoints(float fromPoint, float toPoint)
{
    float x = toPoint - fromPoint;
	return fabs(x);
}

- (void)clearTouches
{
    initialDistance = -1;
}

/*
 disanceBetweenTwoPoints is used to calculate as the method name implies, distance between two points. initialDistance is used to keep track of the distance when touchesBegan method is fired. To zoom in and zoom out, we first need to calculate the distance between the two fingers and store it in initialDistance variable. This is how the touchesBegan method will look like.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];

    NSSet *allTouches = [event allTouches];

    switch ([allTouches count]) {
        case 1: { //Single touch
            
			isDoubleTouch = NO;
			//Get the first touch.
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint touchPoint = [touch locationInView:gantt];
			
			if(isCreatingNewBooking)
				{
				float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;
				// "when" did we click?
				float DateWindow = AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();
				if(DateWindow < 0) 	return;// Bug fix - sometimes displayend is less then displaystart, and we end in a dead-end loop.
				float hours = DateWindow/3600;  // number of hours we want to draw
				float width = AppDelegate->ganttviewcontroller.gantt.frame.size.width;//	rect.size.width;
				float graphWidth = width-RESOURCENAMEWIDTH;
				float pixelsPrHour = graphWidth/hours;
				float pixelsPrMinute = pixelsPrHour/60;
				float pixelsPrSecond = pixelsPrMinute/60;
				
				double secondsIntoView = (touchPoint.x-RESOURCENAMEWIDTH)/pixelsPrSecond;
				
				Date timeClicked = Date((NSTimeInterval) (AppDelegate.displayStart.nstimeInterval()+secondsIntoView) );	// gmt+2
				// Align to 1/4 hours
				timeClicked = timeClicked.ClosestQuarter();
				
				DLog(@"Time Clicked:%@ Clicked %f = %f", timeClicked.nsdate(), touchPoint.x, (touchPoint.x-RESOURCENAMEWIDTH));
				// find the resource
				for(Resource* res in AppDelegate->viewData.Resources)
					{
					CGRect resourceBox = res.pickRectangle;
					if(resourceBox.size.width == resourceBox.size.height == 1)  // inactive resource
						continue;
					//					resourceBox.origin.x = RESOURCENAMEWIDTH;
					resourceBox.size.width = graphWidth;
					if (CGRectContainsPoint(resourceBox, touchPoint)) // clicked resource
						{
						bool foundBooking = NO;
						if(touchPoint.x < RESOURCENAMEWIDTH)    // touched left part, select/deselect resources
							{
							res.Selected = !res.Selected;
							[gantt setNeedsDisplay];
							[AppDelegate->ganttviewcontroller.gantt setNeedsDisplay];
							BookingDragMode = NotDragging;
							foundBooking = YES;
							}
						else
							{
							for(ResourceAndTime* b in AppDelegate->theNewBookingControlller->BookedResources)

//							for(int b=0;b<[AppDelegate->theNewBookingControlller->BookedResources count];b++)
								{
//                                ResourceAndTime* resource = ((ResourceAndTime*)[AppDelegate->theNewBookingControlller->BookedResources objectAtIndex:b]);
								if(b.RE_KEY == res.RE_KEY)	// we are picking a existing new booking
									{
									if(res.Selected == NO)	// Clicked a non-selected resource
										{
										for(Resource* r in AppDelegate->viewData.Resources)
											r.Selected = NO;
										res.Selected = YES;
										}
									
									lastPickedResource = b;
									// Start or end?
									double to=b.TO_TIME.nstimeInterval();
									double clk = timeClicked.nstimeInterval();
									double from=b.FROM_TIME.nstimeInterval();
									
									double t1=fabs(from-clk);
									double t2=fabs(to-clk);
									
									float clickPrecision = 60*45*5;
									
									if(clk < from-clickPrecision || clk > to+clickPrecision)
										BookingDragMode = NotDragging;
									else
										if( clk > from && clk < to)
											BookingDragMode = DragModeMoveBooking;
										else 
											if(t1<t2) // closest to start
												BookingDragMode = DragModeMoveStart;
											else
												BookingDragMode = DragModeMoveEnd;
									
									if(BookingDragMode == DragModeMoveEnd) // end
										{
										if(clk > from)
											b.TO_TIME = timeClicked;
										}
									else if(BookingDragMode == DragModeMoveStart)
										{
										if(clk < to)
											b.FROM_TIME = timeClicked;
										}
									else
										{
										double span = to-from;
										b.FROM_TIME = Date(timeClicked-span/2).ClosestQuarter();
										b.TO_TIME =  Date(timeClicked+span/2).ClosestQuarter();
										}
									
									[gantt setNeedsDisplay];
									[AppDelegate->ganttviewcontroller.gantt setNeedsDisplay];
									foundBooking=YES;
									}
								}
							if(foundBooking == NO)
								{
								DLog(@"ADD NEW BOOKING TO AppDelegate->theNewBookingControlller->BookedResources");
								for(Resource* res in AppDelegate->viewData.Resources)
									if(res.Selected == YES)	// Clicked a non-selected resource
										{
										ResourceAndTime *C = [[ResourceAndTime alloc] init];
										C.RE_KEY = res.RE_KEY;
										C.RE_NAME = res.RE_NAME;
										C.FROM_TIME = timeClicked;
										C.TO_TIME = timeClicked.After(0,0,15);	// least 15 minute booking
                                        [AppDelegate->theNewBookingControlller->BookedResources addObject:C];
                                        [C release];
										BookingDragMode=DragModeMoveEnd;
										}
								[gantt setNeedsDisplay];
								return;
								}
							}// did not click resource name
						} // clicked resource
					}// for all resources
				
				}
			
			else switch ([touch tapCount]) // if not creating new booking
				{
					case 1: //Single Tap.
					{
					UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
					SingleTouchPoint = [touch locationInView:gantt];
					FirstSingleTouchPoint = SingleTouchPoint;
                    //Start a timer for 2 seconds.
					} break;
					case 2: {//Double tap.
					} break;
				}
        } break;
        case 2: { //Double Touch
            isDoubleTouch=true;
            
			//Track the initial distance between two fingers.
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            CGPoint t1 = [touch1 locationInView:gantt];
            CGPoint t2 = [touch2 locationInView:gantt];
            
            initialDistance = distanceBetweenTwoPoints(t1.x,t2.x);
        } break;
        default:
            break;
    }
    
}
/*
 We get the first touch objects at index 0 and 1 and then we calculate the initial distance between the two points. This is how the distanceBetweenTwoPoints method looks like*/
/*
 In touchesMoved event, we find out if there are at least two touches on the screen. We then get the touch object at index 0 and 1, calculate the distance between the finalDistance and the initialDistance. If the initialDistance is greater then the finalDistance then we know that the image is being zoomed out else the image is being zoomed in. This is how the source code looks like*/
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];

	//    if([timer isValid])
	//        [timer invalidate];
    
    NSSet *allTouches = [event allTouches];
    
	UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
	CGPoint touchPoint = [touch locationInView:gantt];
	
	switch ([allTouches count])
    {
        case 1:
		{
		if(isCreatingNewBooking)
			{
			if([AppDelegate->theNewBookingControlller->BookedResources count] == 0)	// Dragging outside a booking, and there is no bookings
				return;
			float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;
			// "when" did we click?
			float DateWindow = AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();
			if(DateWindow < 0) 	return;// Bug fix - sometimes displayend is less then displaystart, and we end in a dead-end loop.
			float hours = DateWindow/3600;  // number of hours we want to draw
			float width = AppDelegate->ganttviewcontroller.gantt.frame.size.width;//	rect.size.width;
			float graphWidth = width-RESOURCENAMEWIDTH;
			float pixelsPrHour = graphWidth/hours;
			float pixelsPrMinute = pixelsPrHour/60;
			float pixelsPrSecond = pixelsPrMinute/60;
			
			double secondsIntoView = (touchPoint.x-RESOURCENAMEWIDTH)/pixelsPrSecond;
			
			Date timeClicked = Date((NSTimeInterval) (AppDelegate.displayStart.nstimeInterval()+secondsIntoView) );	// gmt+2
			// Align to 1/4 hours
			timeClicked = timeClicked.ClosestQuarter();

			double to=lastPickedResource.TO_TIME.nstimeInterval();
			double clk = timeClicked.nstimeInterval();
			double from=lastPickedResource.FROM_TIME.nstimeInterval();
			
			if(BookingDragMode == DragModeMoveEnd) // end
				{
				if(clk > from)
					{
					for(int b=0;b<[AppDelegate->theNewBookingControlller->BookedResources count];b++)
                        {
                        ResourceAndTime *resource = ((ResourceAndTime*)[AppDelegate->theNewBookingControlller->BookedResources objectAtIndex:b]);
                        for(size_t i=0;i<[AppDelegate->viewData.Resources count];i++)
							if(resource.RE_KEY == ((Resource*)[AppDelegate->viewData.Resources objectAtIndex:i]).RE_KEY)
								if(((Resource*)[AppDelegate->viewData.Resources objectAtIndex:i]).Selected)
									resource.TO_TIME = timeClicked;
                        }
					}
				}
			else if(BookingDragMode == DragModeMoveStart)
				{
				if(clk < to)
					for(int b=0;b<[AppDelegate->theNewBookingControlller->BookedResources count];b++)
                        {
                        ResourceAndTime *resource = ((ResourceAndTime*)[AppDelegate->theNewBookingControlller->BookedResources objectAtIndex:b]);
                        for(size_t i=0;i<[AppDelegate->viewData.Resources count];i++)
							if(resource.RE_KEY == ((Resource*)[AppDelegate->viewData.Resources objectAtIndex:i]).RE_KEY)
								if(((Resource*)[AppDelegate->viewData.Resources objectAtIndex:i]).Selected)
									resource.FROM_TIME = timeClicked;
                        }
				}
			else if(BookingDragMode == DragModeMoveBooking)
				{
				double span = to-from;
					for(int b=0;b<[AppDelegate->theNewBookingControlller->BookedResources count];b++)
                    {
					ResourceAndTime *resource = ((ResourceAndTime*)[AppDelegate->theNewBookingControlller->BookedResources objectAtIndex:b]);
					for(size_t i=0;i<[AppDelegate->viewData.Resources count];i++)
						if(resource.RE_KEY == ((Resource*)[AppDelegate->viewData.Resources objectAtIndex:i]).RE_KEY)
							if(((Resource*)[AppDelegate->viewData.Resources objectAtIndex:i]).Selected)
								{
								resource.FROM_TIME = Date(timeClicked-span/2).ClosestQuarter();
								resource.TO_TIME =  Date(timeClicked+span/2).ClosestQuarter();
								}
                    }
                }

			[gantt setNeedsDisplay];

			/*
			for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)
				{
				CGRect resourceBox = AppDelegate->viewData.Resources[i].pickRectangle;
				resourceBox.origin.x = RESOURCENAMEWIDTH;
				resourceBox.size.width = graphWidth;
				if (CGRectContainsPoint(resourceBox, touchPoint))	// clicked the "BAR"
					{
					bool foundBooking = NO;
					for(int b=0;b<AppDelegate->theNewBookingControlller->BookedResources.size();b++)
						{
						if(AppDelegate->theNewBookingControlller->BookedResources[b].RE_KEY == AppDelegate->viewData.Resources[i].RE_KEY)	// we are picking a existing new booking
							{
							if(BookingDragMode) // end
								{
								if(timeClicked.nstimeInterval() > AppDelegate->theNewBookingControlller->BookedResources[b].FROM_TIME.nstimeInterval())
									AppDelegate->theNewBookingControlller->BookedResources[b].TO_TIME = timeClicked;
								}
							else // dragging start
								if(timeClicked.nstimeInterval() < AppDelegate->theNewBookingControlller->BookedResources[b].TO_TIME.nstimeInterval())
									AppDelegate->theNewBookingControlller->BookedResources[b].FROM_TIME = timeClicked;
							
							[gantt setNeedsDisplay];
							foundBooking=YES;
							}
						}
					if(foundBooking == NO)
						{
						DLog(@"ADD NEW BOOKING TO AppDelegate->theNewBookingControlller->BookedResources");
						ResourceAndTime C;
						C.RE_KEY = AppDelegate->viewData.Resources[i].RE_KEY;
						C.RE_NAME = AppDelegate->viewData.Resources[i].RE_NAME;
						C.FROM_TIME = timeClicked;
						C.TO_TIME = timeClicked.HoursAfter(1);
						AppDelegate->theNewBookingControlller->BookedResources.push_back(C);
						[gantt setNeedsDisplay];
						}
					}
				}*/
			}// if creating new booking
		else
			{
			if(isDoubleTouch)
				{
				isDoubleTouch = NO;
				SingleTouchPoint = touchPoint;
				break;
				}
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint touchPoint = [touch locationInView:gantt];
			CGPoint diff;
			diff.x = SingleTouchPoint.x-touchPoint.x;
			diff.y = SingleTouchPoint.y-touchPoint.y;
			/*		if(touchPoint.x < 20) // We are dragging in the resource names list, zoom Y
			 {
			 AppDelegate.ganttBookingHeight = ((touchPoint.y+30)*0.03)+10;
			 if(AppDelegate.ganttBookingHeight < 10)
			 AppDelegate.ganttBookingHeight=10;
			 if(AppDelegate.ganttBookingHeight > 30)
			 AppDelegate.ganttBookingHeight=30;
			 [self.gantt setNeedsDisplay];
			 return;
			 }
			 */		
			//The image is being panned (moved left or right)
/*			float w=AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();
			AppDelegate.displayStart = AppDelegate.displayStart+diff.x*w/AppDelegate.ganttDisplayWidth;
			AppDelegate.displayEnd = AppDelegate.displayEnd+diff.x*w/AppDelegate.ganttDisplayWidth;
*/			
//			AppDelegate.displayStartY = AppDelegate.displayStartY+diff.y;
/*			int ResourceCount = 0;
			for(size_t i=0;i< AppDelegate->viewData.Resources.size() ; i++)
				if(AppDelegate->viewData.Resources[i].bookings.size() != 0 || AppDelegate->viewData.Resources[i].RE_KEY == -1)
					ResourceCount++;*/
/*			
			if(AppDelegate.displayStartY > AppDelegate.ganttResourcesSizeY-AppDelegate.ganttDisplayHeight)
				AppDelegate.displayStartY = AppDelegate.ganttResourcesSizeY-AppDelegate.ganttDisplayHeight;
			
			if(AppDelegate.displayStartY < 0)
				AppDelegate.displayStartY=0;
			*/
			[self.gantt setNeedsDisplay];
			SingleTouchPoint = touchPoint;
			}
		} break;
        case 2: {
/*			//The image is being zoomed in or out.
            
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
			//Calculate the distance between the two fingers.
            CGPoint t1 = [touch1 locationInView:gantt];
            CGPoint t2 = [touch2 locationInView:gantt];
            
            float finalDistance = distanceBetweenTwoPoints(t1.x,t2.x);
            if(initialDistance == finalDistance)
                break;
            
			float dist = finalDistance-initialDistance;
            if((AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval() > 3600*4 && dist > 0) || (AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval() < 3600*24*5 && dist < 0)) // zoom no closer then four hour, no further then 5 days
				{
				float w=AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();
				AppDelegate.displayStart = AppDelegate.displayStart + dist*w/500;
				AppDelegate.displayEnd = AppDelegate.displayEnd - dist*w/500;
				}
			isDoubleTouch=YES;
            initialDistance = finalDistance;    // continue from here
			
            [self.gantt setNeedsDisplay];*/
        } break;
	}
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	isDoubleTouch = false;
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"TestNotification"])
        DLog (@"Successfully received the test notification!");
	
	[self ShowMyBookings:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
	{
		case 1:
		{
		if(isDoubleTouch)
			{
			isDoubleTouch = NO;
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint touchPoint = [touch locationInView:gantt];
			SingleTouchPoint = touchPoint;
			break;
			}
		//The image is being panned (moved left or right)
		UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
		CGPoint touchPoint = [touch locationInView:gantt];
		CGPoint diff;
		diff.x = FirstSingleTouchPoint.x-touchPoint.x;
		diff.y = FirstSingleTouchPoint.y-touchPoint.y;
		
		DLog(@"Diff X:%f Y:%f", diff.x, diff.y);
		
		if(fabs(diff.x) < 20 && fabs(diff.y) < 20)// we clicked a booking - maybe
			{
			for(Resource* res in AppDelegate->viewData.Resources)
				{
				if (CGRectContainsPoint(res.pickRectangle, touchPoint))	// clicked the resource name
					{
					//					if (CGRectContainsPoint(AppDelegate->viewData.Resources[i].selectRectangle, touchPoint))	// clicked the resource name
						{
						res.Selected = !res.Selected;
						[self.gantt setNeedsDisplay];
						return;
						}
					/*
					if(AppDelegate->viewData.Resources[i].Unfolded == YES)	// if selected resource is open, close all
						{
						AppDelegate->viewData.Resources[i].Unfolded = NO;
						[self.gantt setNeedsDisplay];
						return;
						}
					for(size_t z=0;z<AppDelegate->viewData.Resources.size();z++)	// collapse all resources
						AppDelegate->viewData.Resources[z].Unfolded = NO;
					AppDelegate->viewData.Resources[i].Unfolded = YES;				// unfold selected resource
					[self.gantt setNeedsDisplay];
					return;*/
					}
				
				for(int b=[res.bookings count]-1;b>-1;b--) // Check from behind, so we check the smaller (drawn-on-top) bookings first
					{
					if (CGRectContainsPoint(((Booking*)[res.bookings objectAtIndex:b]).pickRectangle, touchPoint))
						{
						cout << "Clicked booking with ID " << ((Booking*)[res.bookings objectAtIndex:b]).BO_KEY << endl;						
						AppDelegate.bookingDetailController->book = ((Booking*)[res.bookings objectAtIndex:b]);//&AppDelegate->viewData.Resources[i].bookings[b];
						AppDelegate.selected_BO_KEY = AppDelegate.bookingDetailController->book.BO_KEY;
						[AppDelegate.bookingDetailController.table reloadData];
						isShowingBookingDetailView=YES;
						[self presentModalViewController:AppDelegate.bookingDetailController animated:YES];
						return;
						}
					}
				}
			}
		}
	}
}

-(IBAction) ShowMyBookings:(bool)animated
{
	if(isShowingMyBookings)// || isShowingBookingDetailView)
		return;
	isShowingMyBookings=YES;
//	NSLog(@"isShowingMyBookings = YES");
	[self presentModalViewController:AppDelegate.MyBookingsAndDrillDown animated:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
//	NSLog(@"isShowingMyBookings 2 = NO");
	isShowingMyBookings=NO;
}

-(void)viewWillAppear:(BOOL)animated
{
//	NSLog(@"isShowingMyBookings 1 = NO");
	isShowingMyBookings=NO;
//	[self.gantt setNeedsDisplay];
//	[self.gantt setNeedsLayout];
}

-(BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
	return YES;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// not done starting
	if([AppDelegate isDoneGettingInitData] == NO)
		return YES;
	// Approve landscape
	
	if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
		{
		return YES;
		}
	if(isShowingBookingDetailView)
		return NO;
		
	[self ShowMyBookings:YES];
	return NO;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}

-(IBAction) StartNewBooking
{
	
	[AppDelegate->theNewBookingControlller.confirmBookingButton setEnabled:NO];

	[AppDelegate->theNewBookingControlller.ClientButton setTitle:@"Select Client" forState:UIControlStateNormal];
	[AppDelegate->theNewBookingControlller.ProjectButton setTitle:@"Select Project" forState:UIControlStateNormal];
	[AppDelegate->theNewBookingControlller.FolderButton setTitle:@"Select Folder" forState:UIControlStateNormal];
	
	[AppDelegate->theNewBookingControlller.ProjectButton setEnabled:NO];
	[AppDelegate->theNewBookingControlller.FolderButton setEnabled:NO];

	// Check if we have any resources selected

    if(	AppDelegate->theNewBookingControlller->BookedResources == nil)
        AppDelegate->theNewBookingControlller->BookedResources = [[NSMutableArray alloc] init];
    [AppDelegate->theNewBookingControlller->BookedResources removeAllObjects];

    
	bool HasBookingsSelected=NO;
	for(Resource* res in AppDelegate->viewData.Resources)
		if(res.Selected)
			{
			HasBookingsSelected=YES;
			break;
			}
	
	if(HasBookingsSelected == NO)
		{

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please select one or more resources for the new booking, before entering the booking view" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
/*
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:@"Information"];
		[alert setMessage:@"Please select one or more resources for booking, before entering the booking view"];
		[alert setDelegate:self];
		[alert addButtonWithTitle:nil];
		[alert addButtonWithTitle:@"OK"];*/
		[alert show];
		[alert release];
		return;
		}
	
	AppDelegate->NewBookingButton.title = @"New booking";
	
	AppDelegate->theNewBookingControlller.activityIndicator = self.activityIndicator;
	AppDelegate->theNewBookingControlller.pickedDate = self.pickedDate;
	AppDelegate->theNewBookingControlller.buttonWithDateLabel = self.buttonWithDateLabel;
	AppDelegate->theNewBookingControlller.buttonWithCombinationLabel = self.buttonWithCombinationLabel;
	AppDelegate->theNewBookingControlller.GanttToolBar = self.GanttToolBar;
	AppDelegate->theNewBookingControlller.isCreatingNewBooking = self.isCreatingNewBooking;
	AppDelegate->theNewBookingControlller.gantt = self.gantt;
	
	GanttView *asd = self.gantt;
	[asd removeFromSuperview];
	asd.frame = CGRectMake(10,248,994,466);
	[AppDelegate->theNewBookingControlller.view addSubview:asd];
	[AppDelegate->theNewBookingControlller.view setNeedsLayout];
	[asd setNeedsLayout];
	[asd setNeedsDisplay];

//	AppDelegate.displayStartY = 0; // Zoom to top
	
	int HOURLINEYSTART=28;
	
	CGRect scrollViewFrame = CGRectMake(1024-gantt.RESOURCENAMEWIDTH,-HOURLINEYSTART,1024-gantt.RESOURCENAMEWIDTH, 768-HOURLINEYSTART-40);
	[gantt.invisibleScrollView scrollRectToVisible:scrollViewFrame animated:YES];
	
    for(Resource *res in AppDelegate->viewData.Resources)// for all resources
		res.includeInNewBookingView = res.Selected;
	
	AppDelegate->theNewBookingControlller.isCreatingNewBooking = isCreatingNewBooking = YES;
	
	[gantt.invisibleScrollView setUserInteractionEnabled:NO];
	
	[self presentModalViewController:AppDelegate.theNewBookingControlller animated:NO];
}


/*
-(void)handleSwipeGesture:(UIGestureRecognizer *)sender
{
	DLog(@"");
	int a=0;
*/
-(void)handlelongPressGesture:(UILongPressGestureRecognizer *)sender
{
	
	if(UIGestureRecognizerStateBegan == sender.state)
		{
		if(isCreatingNewBooking)
			{
			UIAlertView *alert = [[UIAlertView alloc] init];
			[alert setTitle:@"Delete?"];
			[alert setMessage:@"Remove resource from booking?"];
			[alert setDelegate:self];
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			alert.tag = 999;
			[alert show];
			[alert release];
			}
		else
			{
			for(Resource* res in AppDelegate->viewData.Resources)
				{
				if (CGRectContainsPoint(res.selectRectangle, FirstSingleTouchPoint))	// clicked the resource name
					{
					for(Resource* j in AppDelegate->viewData.Resources)
						j.Selected=NO;
					[self.gantt setNeedsDisplay];
					return;
					}				
				if (CGRectContainsPoint(res.pickRectangle, FirstSingleTouchPoint))	// clicked the resource name
					{
					for(Resource* j in AppDelegate->viewData.Resources)
						j.Unfolded=NO;
					res.Unfolded = YES;
					[self.gantt setNeedsDisplay];
					return;
					}
				}
			}
		//else	// in normal gantt view. Find slots with same BO_KEY and highlight them
			{
				{
				for(Resource* res in AppDelegate->viewData.Resources)
					{
					for(Booking* b in res.bookings)
						{
						if (CGRectContainsPoint(res.selectRectangle, FirstSingleTouchPoint))	// clicked the resource name
							{
							for(Resource* j in AppDelegate->viewData.Resources)
								j.Selected=NO;
							[self.gantt setNeedsDisplay];
							return;
							}

						if (CGRectContainsPoint(b.pickRectangle, FirstSingleTouchPoint))
							{
							int BOKEY=b.BO_KEY;
							cout << "LongPress booking with ID " << BOKEY << endl;
							// Find other bookings with same BO_KEY
							for(Resource* j in AppDelegate->viewData.Resources)
								for(Booking* c in j.bookings)
									{
									if(c.BO_KEY == BOKEY)
										{
										c.BOKEYSELECTED = YES;
										j.Selected = YES;
										}
									else
										{
										c.BOKEYSELECTED = NO;
										}
									}
							[gantt setNeedsDisplay];
							return;	// done, we are
							}
						}
					}
				// if we come here, the pres was outside any bookings. Clear BOKEYSELECTED bits
				for(Resource* res in AppDelegate->viewData.Resources)
					for(Booking* b in res.bookings)
						b.BOKEYSELECTED = NO;
				[gantt setNeedsDisplay];
				return;	// done, we are
				}
			}
		}
	
    if(UIGestureRecognizerStateChanged == sender.state)
		{
        // Do repeated work here (repeats continuously) while finger is down
		}
	
    if(UIGestureRecognizerStateEnded == sender.state)
		{
        // Do end work here when finger is lifted
		}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 999)
		{
		
		if (buttonIndex == 0)
			{
            [AppDelegate->theNewBookingControlller->BookedResources removeObject:lastPickedResource];
			[gantt setNeedsDisplay];
			}
		else if (buttonIndex == 1)
			{
			// No
			}
		}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView                                               // any offset changes
{
//	NSLog(@".%f",scrollView.contentOffset.x);
	
	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;

	float positionInPixels = scrollView.contentOffset.x-(1024-RESOURCENAMEWIDTH);
	
//	NSLog(@"scrollViewDidScroll : %f", positionInPixels);

	float scrollSizeInPixels = 1024-RESOURCENAMEWIDTH;
	
	float thisPos=positionInPixels/scrollSizeInPixels;
	float numberOfSecondsInView = AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();	// number of seconds in view
	
	static float lastPos = 0.0f;
	float delta = thisPos-lastPos;
	lastPos = thisPos;

	AppDelegate.displayStartY = scrollView.contentOffset.y;
//	NSLog(@"%f : %f : %f",scrollView.contentOffset.y, ypos, AppDelegate.displayStartY);
	[self.gantt setNeedsDisplay];

//	NSLog(@"delta : %f", delta);
	if(positionInPixels == 0)
		{
		lastPos = thisPos;
		return;	// we stopped, don't update x position
		}
	
	AppDelegate.displayStart = AppDelegate.displayStart+delta*numberOfSecondsInView;
	AppDelegate.displayEnd = AppDelegate.displayEnd+delta*numberOfSecondsInView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2) // any zoom scale changes
{
//	NSLog(@"%f", gantt.invisibleScrollView.zoomScale);
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	
}
// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES

// IOS 5 only

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;

/*
 invisibleScrollView.contentSize = CGSizeMake((1024-RESOURCENAMEWIDTH)*3,7700);
 invisibleScrollView.scrollsToTop = NO;
 invisibleScrollView.contentOffset = CGPointMake(1024-RESOURCENAMEWIDTH, 0);
*/
	
	AppDelegate.displayStart = AppDelegate.displayStart.HoursAfter(12).StartOfDay();
	AppDelegate.displayEnd = AppDelegate.displayEnd.HoursAfter(12).StartOfDay();
	
	// need more data?
//	double viewStart = AppDelegate.displayStart.nstimeInterval();
//	double viewEnd = AppDelegate.displayEnd.nstimeInterval();
//	float numberOfDaysInView = (viewEnd-viewStart) / (24*60*60);

//	NSLog(@"scrollViewWillEndDragging");
//	NSLog(@"	velocity.x:%f target:%f\n",velocity.x, targetContentOffset->x);

	if(1)// fabs(velocity.x) > fabs(velocity.y))	// primarily x motion
		{
		if(velocity.x > 0)
			{
			targetContentOffset->x = ((1024-RESOURCENAMEWIDTH)*2);
			}
		else
			{
			targetContentOffset->x = 0;
			}
		}
//	NSLog(@"*********velocity.x:%f target:%f\n",velocity.x, targetContentOffset->x);
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//	NSLog(@"scrollViewDidEndDragging");
	if(decelerate)
		{
		// where will we end?
//		float DateWindow = AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();
		}	
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView   // called on finger up as we are moving
{

	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView      // called when scroll view grinds to a halt
{
//	NSLog(@"scrollViewDidEndDecelerating at X:%f", scrollView.contentOffset.x);
	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt.RESOURCENAMEWIDTH;
	[scrollView setContentOffset:CGPointMake(1024-RESOURCENAMEWIDTH,scrollView.contentOffset.y)];	// reset
	// Snap to 00:00
	AppDelegate.displayStart = AppDelegate.displayStart.HoursAfter(12).StartOfDay();
	AppDelegate.displayEnd = AppDelegate.displayEnd.HoursAfter(12).StartOfDay();
	
	// need more data?
	double viewStart = AppDelegate.displayStart.nstimeInterval();
	double viewEnd = AppDelegate.displayEnd.nstimeInterval();
	
	double dataStart = AppDelegate.dataScopeStart.nstimeInterval();
	double dataEnd = AppDelegate.dataScopeEnd.nstimeInterval();
	
//	if(both before view start)
	// both after view end
	// datastart > viewstart
//	dataend < viewend
		
	if(dataEnd < viewEnd || dataStart > viewStart)
		[self RequestBookingData];
	
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2) // called before the scroll view begins zooming its content
{
	NSLog(@"scrollViewWillBeginZooming");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale // scale between minimum and maximum. called after any 'bounce' animations
{
	NSLog(@"scrollViewDidEndZooming");
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView   // return a yes if you want to scroll to the top. if not defined, assumes YES
{
	return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView      // called when scrolling animation finished. may be called immediately if already at top
{
	
}


@end
