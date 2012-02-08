//
//  MyBookingsController.m
//  iOdyssey
//
//  Created by Michael Holm on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyBookingsController.h"
#import "MyBookingCell.h"
#import "EmptyBookingCell.h"
#import "DateViewController.h"

#import "iOdysseyAppDelegate.h"
#import "CustomCellBackgroundView.h"

@implementation MyBookingsController

@synthesize table, bookingDetailController, ResourceName, preferencesController, aboutController, DisplayScopeLabel, UpdatedDateLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	//	DLog(@"initWithNibName"); 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
	//	DLog(@"initWithNibName return"); 
    return self;
}

- (void)dealloc
{
	[DateAndTimeFormatter release];
	[TimeFormatter release];
	[ShortDateTimeFormatter release];
	[DayNameFormatter release];
    [table release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	DLog(@"didReceiveMemoryWarning"); 
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	
	// AppDelegate does not exist yet, so kep our own timezone
	
	NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

	DateAndTimeFormatter = [[NSDateFormatter alloc] init];
	[DateAndTimeFormatter setDateFormat:@"dd/MM-yyyy HH:mm"];
	[DateAndTimeFormatter setTimeZone:timeZone];

	TimeFormatter = [[NSDateFormatter alloc] init];
	[TimeFormatter setDateFormat:@"HH:mm"];
	[TimeFormatter setTimeZone:timeZone];

	ShortDateTimeFormatter = [[NSDateFormatter alloc] init];
	[ShortDateTimeFormatter setDateFormat:@"ddMMMyy"];
	[ShortDateTimeFormatter setTimeZone:timeZone];

	DayNameFormatter = [[NSDateFormatter alloc] init];
	[DayNameFormatter setDateFormat:@"cccc"];
	[DayNameFormatter setTimeZone:timeZone];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
	[table release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	switch (toInterfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
		[self RefreshView];
		break;
		
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		[self dismissModalViewControllerAnimated:YES];
		break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	DLog(@"indexPath.colum:%d indexPath.row:%d ", indexPath.section, indexPath.row); 
	if(AppDelegate.IsIpad)
		return 75;

	int myResourceKey = AppDelegate.loginData.Login.RE_KEY;
	for(Resource *res in AppDelegate->viewData.Resources)
		if(res.RE_KEY == myResourceKey)
			if([res.bookings count] == 0)
				return 430;
			else
				return 75;
	return 75;	// quiet compiler
}

bool BookingStartTimeSortPredicate(Booking* d1, Booking* d2)
{
	return d1.FROM_TIME.nstimeInterval() < d2.FROM_TIME.nstimeInterval();
}


-(void) RefreshView
{
	cout << "MyBookingsController :: RefreshView" << endl;

	int myResourceKey = AppDelegate.loginData.Login.RE_KEY;
	
	NSDate *a=[NSDate date];
	Date today(a);
	[UpdatedDateLabel setText:today.FormatForUpdatedLabel()];

	[ResourceName setText:AppDelegate.loginData.Login.FULL_NAME];
	
	// Sort entries by date
	for(Resource* res in AppDelegate->viewData.Resources)
		if(res.RE_KEY == myResourceKey)
			{
			[res sortBookingsByStartDate];
			break;
			}

	[DisplayScopeLabel setText:[NSString stringWithFormat:@"%@ - %@", AppDelegate.dataScopeStart.FormatForDataScopeView(), AppDelegate.dataScopeEnd.FormatForDataScopeView()]];
	[table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    // Find the selected booking in the my bookings controller
	for(Resource* res in AppDelegate->viewData.Resources)
		for(Booking* b in res.bookings)
            if(b.BO_KEY == AppDelegate.selected_BO_KEY)
				{
				BookingDetailController *cnt=AppDelegate.MyBookingsAndDrillDown.myBookingsController->bookingDetailController;
				cnt.book = b;
				[cnt.table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
				return;
				}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

	Date start = AppDelegate.displayStart.DaysBefore(AppDelegate.DataScopeBack);
	Date end = AppDelegate.displayEnd.DaysAfter(AppDelegate.DataScopeForward);

	int nDays = 0;
	while(!start.IsSameDayAs(end))
		{
		nDays++;
		start = start.DaysAfter(1);
		}
	
    return nDays;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	Date start = AppDelegate.dataScopeStart;
	int nDays = 0;
	while(nDays<section)
		{
		start = start.DaysAfter(1);
		nDays++;
		}

	return start.FormatForMyBookings();
	
	return @"ERROR 0x2343243";
}

-(void) RecalcBookingsPrDayTable
{
	Date start = AppDelegate.dataScopeStart;
	Date end = AppDelegate.dataScopeEnd;
	
	BookingsPrDay.clear();
	BookingsPrDay.resize(start.daysBetweenDate(end));
	
	int myResourceKey = AppDelegate.loginData.Login.RE_KEY;
	for(Resource* res in AppDelegate->viewData.Resources)
		{
		if(res.RE_KEY == myResourceKey)
			{
			// How many of the bookings are today?
			for(Booking* b in res.bookings)
				{
				int DayNr = AppDelegate.dataScopeStart.daysBetweenDate(b.FROM_TIME);
				BookingsPrDay[DayNr]++;
				}
			}
		}
}


-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	[self RecalcBookingsPrDayTable];
	if(BookingsPrDay.size() > section)
		return BookingsPrDay[section];
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyBookingCell *cell = (MyBookingCell *)[table dequeueReusableCellWithIdentifier: nil]; //@"MyBookingCell"
	
	if (cell == nil)
		{
		NSString *nibName;
		if(AppDelegate.IsIpad)
			nibName = @"MyBookingCell_ipad";
		else
			nibName = @"MyBookingCell_iphone";
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
		for(id currentObject in topLevelObjects)
			{
			if([currentObject isKindOfClass:[UITableViewCell class]])
				{
				cell = (MyBookingCell *)currentObject;
				break;
				}
			}
	}
	
	int myResourceKey = AppDelegate.loginData.Login.RE_KEY;

	for(Resource* res in AppDelegate->viewData.Resources)
		{
		if(res.RE_KEY == myResourceKey)
			{
			if([res.bookings count] == 0)	// we have no bookings, inform about this
				{
				EmptyBookingCell *cell = (EmptyBookingCell *)[table dequeueReusableCellWithIdentifier:@"EmptyBookingCell"];
				
				if (cell == nil)
					{
					NSString *nibName;
					if(AppDelegate.IsIpad)
						nibName = @"EmptyBookingCell_ipad";
					else
						nibName = @"EmptyBookingCell_iphone";
					NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
					for(id currentObject in topLevelObjects)
						{
						if([currentObject isKindOfClass:[UITableViewCell class]])
							{
							cell = (EmptyBookingCell *)currentObject;
							break;
							}
						}
					}
				return cell;
				}
			
			// Find the right booking for the section
			
			int BookingNr=0;
			int d;
			for(d=0;d<indexPath.section;d++)
				BookingNr+= BookingsPrDay[d];
			BookingNr+= indexPath.row;
			
			Booking* b = (Booking*)[res.bookings objectAtIndex:BookingNr];
			
			[[cell StartTime] setText:[TimeFormatter stringFromDate:b.FROM_TIME.nsdate()]];
			[[cell EndTime] setText:[TimeFormatter stringFromDate:b.TO_TIME.nsdate()]];
			[[cell Component] setText:[NSString stringWithFormat:@"%@ / %@", b.ACTIVITY, b.Folder_name ]];
			
			//			DLog(@" indexPath.section : %d Bookings for day %d: %d\n", indexPath.section, indexPath.section, BookingsPrDay[indexPath.section]);
			
			
			CustomCellBackgroundView *bgView = [[CustomCellBackgroundView alloc] initWithFrame:CGRectZero];
			[bgView setBorderColor:[UIColor blackColor]];
			[bgView setFillColor:[UIColor whiteColor]];
			[bgView setProgressColor:[UIColor colorWithRed:0.7 green:0.9 blue:0.7 alpha:1.0]];
			[bgView setPassedBookingsColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
			[bgView setOpenPassedBookingsColor:[UIColor colorWithRed:1 green:0.6 blue:0.6 alpha:1.0]];
			[bgView setBook:b];

			PCODE pc = b.pcode;
			
			if(pc == P_FINISHED || pc == P_INVOICED || pc == P_APPROVED)
				{
				[cell.signedOffImage setHidden:NO];//setImage:[UIImage imageNamed:@"signedOff.png"]];
				}
			else
				{
				[cell.signedOffImage setHidden:YES];//setImage:nil];
				}
			
			if(BookingsPrDay[indexPath.section] == 1)
				{
				bgView.position = CustomCellBackgroundViewPositionSingle;
				}
			else if (indexPath.row == 0)
				{
				bgView.position = CustomCellBackgroundViewPositionTop;
				}
			else if (indexPath.row == BookingsPrDay[indexPath.section]-1)
				{
				bgView.position = CustomCellBackgroundViewPositionBottom;
				}
			else
				{
				bgView.position = CustomCellBackgroundViewPositionMiddle;
				}
			// Progress
			NSDate* a = [NSDate date];
			Date now(a);
			float t = (now-b.FROM_TIME).nstimeInterval()/(b.TO_TIME.nstimeInterval() - b.FROM_TIME.nstimeInterval());
			bgView.progress = t;
			
			cell.backgroundView = bgView;
			[bgView release];
			
			[[cell Client] setText:b.CL_NAME ];
/*
 enum CStatus{ROS, BKS, BK, A16, A35, HL1, HL2, IO, CNI, CND, P01, NA, MET, TRA, SIP, GRATIS, INVOICED, UNKNOWN, ERROR};
 
 enum PCODE{P_UNKNOWN, P_OPEN, P_FINISHED, P_APPROVED, P_PRECALC, P_PROFORMA, P_INVOICED, P_LOGGEDOUT, P_ERROR};
*/
			NSString* status;
			switch(b.STATUS)
				{
					case ROS: status=@"ROS"; break;
					case BKS: status=@"BKS"; break;
					case BK: status=@"BK"; break;
					case A16: status=@"A16"; break;
					case A35: status=@"A35"; break;
					case HL1: status=@"HL1"; break;
					case HL2: status=@"HL2"; break;
					case IO: status=@"IO"; break;
					case CNI: status=@"CNI"; break;
					case CND: status=@"CND"; break;
					case P01: status=@"P01"; break;
					case NA: status=@"NA"; break;
					case MET: status=@"MET"; break;
					case TRA: status=@"TRA"; break;
					case SIP: status=@"SIP"; break;
					case GRATIS: status=@"GRATIS"; break;
					case INVOICED: status=@"INVOICED"; break;
					case UNKNOWN: status=@"UNKNOWN"; break;
					case ERROR: status=@"ERROR"; break;
				}
			NSString* pcode;
			switch(b.pcode)
				{
					case P_UNKNOWN: pcode=@"UNKNOWN"; break;
					case P_OPEN: pcode=@"OPEN"; break;
					case P_FINISHED: pcode=@"FINISHED"; break;
					case P_APPROVED: pcode=@"APPROVED"; break;
					case P_PRECALC: pcode=@"PRECALC"; break;
					case P_PROFORMA: pcode=@"PROFORMA"; break;
					case P_INVOICED: pcode=@"INVOICED"; break;
					case P_LOGGEDOUT: pcode=@"LOGGEDOUT"; break;
					case P_GRATIS: pcode=@"GRATIS"; break;
					default:
					case P_ERROR: pcode=@"ERROR"; break;
				}
			
			[[cell Activity] setText: [NSString stringWithFormat:@"%@ / %@ / %d / %@", status, pcode, b.BO_KEY , b.NAME]];
		
			
//			[[cell DayLabel] setText:[DayNameFormatter stringFromDate:AppDelegate->viewData.Resources[i].bookings[BookingNr].FROM_TIME.nsdate()]];
//			[[cell DateLabel] setText:[ShortDateTimeFormatter stringFromDate:AppDelegate->viewData.Resources[i].bookings[BookingNr].FROM_TIME.nsdate()]];
			cell.STATUS = b.STATUS;
			cell.book = b;
			return cell;
			}
		}
	
	return cell;
}

- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath
{
	MyBookingCell *cell = (MyBookingCell*)[tableView cellForRowAtIndexPath:indexPath];
	bookingDetailController.book = cell.book;
    [bookingDetailController.table reloadData];
    AppDelegate.selected_BO_KEY = cell.book.BO_KEY;
	
    [self.navigationController pushViewController:bookingDetailController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyBookingCell *cell = (MyBookingCell*)[tableView cellForRowAtIndexPath:indexPath];
	[cell setNeedsDisplay];
	bookingDetailController.book = cell.book;
    [bookingDetailController.table reloadData];
    AppDelegate.selected_BO_KEY = cell.book.BO_KEY;
	
    [self.navigationController pushViewController:bookingDetailController animated:YES];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyBookingCell *cell = (MyBookingCell*)[tableView cellForRowAtIndexPath:indexPath];
	[cell setNeedsDisplay];
}

-(void) ShowPreferences
{
	[self.navigationController pushViewController:preferencesController animated:YES];
}

-(void) ShowAbout
{
	//	[self.navigationController pushViewController:aboutController animated:YES];
	[UIView beginAnimations:@"animation" context:nil];
	[self.navigationController pushViewController:aboutController animated:NO];
	[UIView setAnimationDuration:2];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO]; 
	[UIView commitAnimations];
}








@end
































