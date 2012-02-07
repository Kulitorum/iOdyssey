//
//  ViewData.cpp
//  iOdyssey
//
//  Created by Michael Holm on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ViewData.h"

#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "iOdysseyAppDelegate.h"
#import "Booking.h"

#include <iostream>

using namespace std;

extern bool BookingSortPredicate(const Booking& d1, const Booking& d2);

@implementation ViewDataController

-(id)init
{
	self = [super init];
	if(self)
		{
		}
	return self;
}


-(void) start
{
	timer = [NSTimer scheduledTimerWithTimeInterval:60*5 target:self selector:@selector(RefreshMyBookings) userInfo:nil repeats:YES];	// every 60 seconds
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
    cout << "Got MY booking data, processing" << endl;

	vector<Booking> newBookings;
	if (query.succeeded)
		{
		NSDate *a=[NSDate date];
		Date today(a);
		//		[AppDelegate->MyBookingsAndDrillDown.myBookingsController.UpdatedDateLabel setText:today.FormatForUpdatedLabel()];
		for (SqlResultSet *resultSet in query.resultSets)
			{
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
			
			
			Booking book;
			while ([resultSet moveNext])
				{
				book.clear();
				book.RE_KEY = [ resultSet getInteger: RE_KEY ];
				book.Resource = [[resultSet getString: ResourceKey] copy];
				//book.STATUS
				NSString *status = [resultSet getString: STATUS];
					{
					if ([status compare:@"BKS"] == NSOrderedSame) book.STATUS=BKS;
					else if ([status compare:@"BK"] == NSOrderedSame) book.STATUS=BK;
					else if ([status compare:@"HL1"] == NSOrderedSame) book.STATUS=HL1;
					else if (([status compare:@"HL2"] == NSOrderedSame)) book.STATUS=HL2;
					else if (([status compare:@"35"] == NSOrderedSame)) book.STATUS=GRATIS;
					else book.STATUS = UNKNOWN;
					}
				NSString *pco = [resultSet getString: PCODE];
					{
					book.pcode=P_UNKNOWN;
					if ([pco compare:@"O"] == NSOrderedSame) book.pcode=P_OPEN;
					else if ([pco compare:@"F"] == NSOrderedSame) book.pcode=P_FINISHED;
					else if ([pco compare:@"A"] == NSOrderedSame) book.pcode=P_APPROVED;
					else if (([pco compare:@"P"] == NSOrderedSame)) book.pcode=P_PRECALC;
					else if (([pco compare:@"Q"] == NSOrderedSame)) book.pcode=P_PROFORMA;
					else if (([pco compare:@"I"] == NSOrderedSame)) book.pcode=P_INVOICED;
					else if (([pco compare:@"M"] == NSOrderedSame)) book.pcode=P_LOGGEDOUT;
					else book.pcode = P_UNKNOWN;
					if(book.pcode == P_UNKNOWN)
						DLog(@"UNKNOWN PCODE: %@", pco);
					}
				book.MTYPE = [resultSet getInteger:MTYPE];
				
				book.FROM_TIME = Date([resultSet getDate:FROM_TIME]);//.HoursBefore(2);// GMT+2
				book.TO_TIME = Date([resultSet getDate:TO_TIME]);//.HoursBefore(2);    // GMT+2
				
				book.FIRST_NAME = [[resultSet getString:FIRST_NAME] copy];
				if ( ! [book.FIRST_NAME isKindOfClass:[NSString class]])
					book.FIRST_NAME=@"";
				book.ACTIVITY = [[resultSet getString:ACTIVITY] copy];
				if ( ! [book.ACTIVITY isKindOfClass:[NSString class]])
					book.ACTIVITY=@"";
				if ([book.FIRST_NAME compare:@"<null>"] == NSOrderedSame)   // person
					book.FIRST_NAME = @"";
				book.LAST_NAME = [[resultSet getString:LAST_NAME] copy];
				if ( ! [book.LAST_NAME isKindOfClass:[NSString class]])
					book.LAST_NAME=@"";
				if ([book.LAST_NAME compare:@"<null>"] == NSOrderedSame)   // person
					book.LAST_NAME = @"";
				book.NAME = [[resultSet getString:NAME] copy];
				if ( ! [book.NAME isKindOfClass:[NSString class]])
					book.NAME=@"";
				book.BK_Remark = [[resultSet getString:BK_Remark] copy];
				if ( ! [book.BK_Remark isKindOfClass:[NSString class]])
					book.BK_Remark=@"";
				book.Folder_name = [[resultSet getString:Folder_name] copy];
				if ( ! [book.Folder_name isKindOfClass:[NSString class]])
					book.Folder_name=@"";
				book.Folder_remark = [[resultSet getString:Folder_remark] copy];
				if ( ! [book.Folder_remark isKindOfClass:[NSString class]] || [book.Folder_remark length]==0)
					book.Folder_remark=@"";
				book.TYPE = [[resultSet getString:TYPE] copy];
				book.BS_KEY = [resultSet getInteger:BS_KEY];
				book.BO_KEY = [resultSet getInteger:BO_KEY];
				book.CL_NAME = [[resultSet getString:CL_NAME] copy];
				if ( ! [book.CL_NAME isKindOfClass:[NSString class]])
					book.CL_NAME=@"";
				bool HasBooking = NO;
				for(size_t x=0;x<newBookings.size();x++)
					if(newBookings[x].BS_KEY == book.BS_KEY)
						{
						HasBooking=YES;
						break;
						}
				if(HasBooking == NO)
					newBookings.push_back(book);
				}
			}
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];    [alert show];
			[alert release];   
		}
	// sort booking by length
//	std::sort(newBookings.begin(), newBookings.end(), BookingSortPredicate);
	
	bool isTheSame=YES;
	
	//	iOdysseyAppDelegate *asd = AppDelegate;
	
	NSDate *a=[NSDate date];
	Date today(a);

	// check if there's any changes
	for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)
		if(AppDelegate->viewData.Resources[i].RE_KEY == AppDelegate->loginData.Login.RE_KEY)
			{
			if(AppDelegate->viewData.Resources[i].bookings.size() != newBookings.size())
				{
				isTheSame=NO;
				goto fastExit;
				}
			for(size_t b=0;b<AppDelegate->viewData.Resources[i].bookings.size();b++)
				{
				for(size_t b2=0;b2<newBookings.size();b2++)
					{
					bool OneOfTheBookingsIsToday=NO;
/*					if(AppDelegate->viewData.Resources[i].bookings[b].FROM_TIME.IsSameDayAs(today) || 
					   AppDelegate->viewData.Resources[i].bookings[b].TO_TIME.IsSameDayAs(today) || 
					   newBookings[b2].FROM_TIME.IsSameDayAs(today) || 
					   newBookings[b2].TO_TIME.IsSameDayAs(today))
						OneOfTheBookingsIsToday=YES;

*/
					OneOfTheBookingsIsToday=YES;
					   
					if(OneOfTheBookingsIsToday && (AppDelegate->viewData.Resources[i].bookings[b].BO_KEY == newBookings[b2].BO_KEY ))
						{
						if( AppDelegate->viewData.Resources[i].bookings[b].IsSameAs(newBookings[b2]) == NO)
							{
							isTheSame=NO;
							goto fastExit;
							}
						}
					}
				}	
			}
fastExit:	
	if(isTheSame == NO)
		{
		// delete my bookings
		size_t i;
		for(i=0;i<AppDelegate->viewData.Resources.size();i++)
			if(AppDelegate->viewData.Resources[i].RE_KEY == AppDelegate->loginData.Login.RE_KEY)
				{
				AppDelegate->viewData.Resources[i].bookings.clear();
				break;
				}
		for(size_t n=0;n<newBookings.size();n++)
			AppDelegate->viewData.AddBooking(newBookings[n], AppDelegate->loginData.Login.RE_KEY);    // Store booking in gantt chart
		cout << "updated MY bookings" << endl;
		[AppDelegate.ganttviewcontroller.gantt setNeedsDisplay];
//		[AppDelegate.myBookingsController RefreshView];
/*
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"One of your bookings today was changed. " message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
*/		
		}
	else
		{
		cout << "no change in MY bookings" << endl;
		}

	
	[AppDelegate.ganttviewcontroller.gantt setNeedsDisplay];
	[AppDelegate.myBookingsController RefreshView];// refresh update time and progress bar

	if([AppDelegate isDoneGettingInitData]==YES)
		{
		[AppDelegate.MyBookingsAndDrillDown.activityIndicator stopAnimating];
		[AppDelegate.ganttviewcontroller.activityIndicator stopAnimating];
		}

}

-(void) RequestMyBookingData
{
		if( [AppDelegate isDoneGettingInitData] == NO)
			return;
	
    cout << "Requesting MY booking data" << endl;
	
	if([AppDelegate->scheduler IsConnectedToWIFI] == NO)
		{
#if TARGET_IPHONE_SIMULATOR
#else
		cout << "Not connected to wifi" << endl;
		return;
#endif
		}
//	NSString *request = [NSString stringWithFormat:@"SELECT * FROM  vw_staff_schedule_2 WHERE RE_KEY=%d AND (FROM_TIME BETWEEN '%@' AND '%@') OR (FROM_TIME BETWEEN '%@' AND '%@' AND RE_KEY=%d) AND SITE_KEY = %d", AppDelegate->loginData.Login.RE_KEY, AppDelegate.displayStart.DaysBefore(AppDelegate.DataScopeBack).FormatForSQL(), AppDelegate.displayEnd.DaysAfter(AppDelegate.DataScopeForward).FormatForSQL(), AppDelegate.displayStart.DaysBefore(90).FormatForSQL(),AppDelegate.displayStart.DaysBefore(AppDelegate.DataScopeBack).FormatForSQL(), AppDelegate->loginData.Login.RE_KEY, AppDelegate->loginData.Login.SITE_KEY];
	NSString *request = [NSString stringWithFormat:@"SELECT * FROM  vw_staff_schedule_2 WHERE RE_KEY=%d AND FROM_TIME BETWEEN '%@' AND '%@' AND SITE_KEY = %d", AppDelegate->loginData.Login.RE_KEY, AppDelegate.displayStart.DaysBefore(AppDelegate.DataScopeBack).FormatForSQL(), AppDelegate.displayEnd.DaysAfter(AppDelegate.DataScopeForward).FormatForSQL(), AppDelegate->loginData.Login.SITE_KEY];
	cout << [request UTF8String] << endl;
	[AppDelegate.client executeQuery:request withDelegate:self];
}



-(void) RefreshMyBookings
{
	DLog(@"RefreshMyBookings");
	[self RequestMyBookingData];
}


@end