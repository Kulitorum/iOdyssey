//
//  LoginData.mm
//  iOdyssey
//
//  Created by Michael Holm on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "LoginData.h"

#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "iOdysseyAppDelegate.h"

#include <iostream>
#include <string>

#include "DataManager.h"
extern DataManager Manager;

@implementation LoginData

@synthesize client;

-(void) Refresh
{
	cout << "Requesting LoginData" << endl;

	NSString *server = [NSString stringWithFormat:@"http://%@/isql", [NSString stringWithUTF8String:Manager.SettingsServer.c_str()]];
	self.client = [SqlClient clientWithServer:server Instance:@"" Database: [NSString stringWithUTF8String:Manager.SettingsDatabase.c_str()]
									 Username: [NSString stringWithUTF8String:Manager.SettingsUsername.c_str()] Password: [NSString stringWithUTF8String:Manager.SettingsPassword.c_str()]];
		
//	NSString *request = [NSString stringWithFormat:@"SELECT * FROM  vw_staff_schedule WHERE rv_key = %d AND FROM_TIME BETWEEN '%@' AND '%@'", Manager.RESOURCE_VIEWID, Manager.displayStart.FormatForSQL(), Manager.displayEnd.FormatForSQL()];

	NSString *request = [NSString stringWithFormat:@"EXEC SpUser_Access 'MichaelH',110"];//, Manager.RESOURCE_VIEWID, Manager.displayStart.FormatForSQL(), Manager.displayEnd.FormatForSQL()];
	
	[self.client executeQuery:request withDelegate:self];
		
}


-(void) Clear
{
	Login.clear();
}


- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
    cout << "Got LoginData, processing" << endl;
	
//	iOdysseyAppDelegate *app = AppDelegate;
	
	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
	{
	[self Clear];	// delete old data
	for (SqlResultSet *resultSet in query.resultSets)
		{
		for (int i = 0; i < resultSet.fieldCount; i++)
			{
			[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
			}
		[outputString appendString:@"\r\n--------\r\n"];
		string theFieldList([outputString UTF8String]);
		
		cout << theFieldList << endl;
/*		
		
		Booking book;
		
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
		NSInteger RV_KEY = [resultSet indexForField:@"RV_KEY"];
		NSInteger CL_NAME = [resultSet indexForField:@"CL_NAME"];
		
		//Resource RE_KEY STATUS PCODE MTYPE BS_KEY FROM_TIME TO_TIME BO_KEY FIRST_NAME LAST_NAME NAME BK_Remark Folder_name Folder_remark TYPE RV_KEY CL_NAME
		
		while ([resultSet moveNext])
			{
			for (int i = 0; i < resultSet.fieldCount; i++)
				[outputString appendFormat:@"%@ | ", [resultSet getData:i]];
			[outputString appendString:@"\r\n"];
			
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
			book.PCODE = [resultSet getInteger:PCODE];
			book.MTYPE = [resultSet getInteger:MTYPE];
			
			book.FROM_TIME = Date([resultSet getDate:FROM_TIME]).HoursBefore(2);// GMT+2
			book.TO_TIME = Date([resultSet getDate:TO_TIME]).HoursBefore(2);    // GMT+2
			
			book.FIRST_NAME = [[resultSet getString:FIRST_NAME] copy];
			if ( ! [book.FIRST_NAME isKindOfClass:[NSString class]])
				book.FIRST_NAME=@"";
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
			if ( ! [book.Folder_remark isKindOfClass:[NSString class]])
				book.Folder_remark=@"";
			book.TYPE = [[resultSet getString:TYPE] copy];
			book.BS_KEY = [resultSet getInteger:BS_KEY];
			book.BO_KEY = [resultSet getInteger:BO_KEY];
			book.RV_KEY = [resultSet getInteger:RV_KEY];
			book.CL_NAME = [[resultSet getString:CL_NAME] copy];
			if ( ! [book.CL_NAME isKindOfClass:[NSString class]])
				book.CL_NAME=@"";
			
			
			Manager.viewData.AddBooking(book);    // Store booking in gantt chart
			}*/
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error executing query" message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];    [alert show];
		[alert release];   
	}
	//	string s([outputString UTF8String]);
	//	cout << s;
	
/*	// sort booking by length
    for(size_t i=0;i<Manager.viewData.Resources.size();i++)
	std::sort(Manager.viewData.Resources[i].bookings.begin(), Manager.viewData.Resources[i].bookings.end(), BookingSortPredicate);
	
	
	
    [self.gantt setNeedsDisplay];
	
	[activityIndicator stopAnimating];
*/	
    cout << "Done processing LoginData" << endl;
}


@end
