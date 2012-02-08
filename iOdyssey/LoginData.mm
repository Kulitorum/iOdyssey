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

@implementation LoginDataContainer

@synthesize PASSWRD;
@synthesize USERNAME;
@synthesize FULL_NAME;
@synthesize GROUP_NAME;
@synthesize SITE_NAME;
@synthesize LEGAL_ENTIRY;
@synthesize SECTION;
@synthesize DESCRIPTION1;
@synthesize ACCESS_RIGHTS;	// Bool
@synthesize SITE_KEY;		// Shortcut, use when requesting booking and resource data, "AND SITE_KEY=%d"
@synthesize USER_KEY;		// Whoami
@synthesize STAFF_CL_KEY;   // index into client database
@synthesize RE_KEY;			// 1543

-(void) clear
{
	PASSWRD = USERNAME = FULL_NAME = GROUP_NAME = SITE_NAME = LEGAL_ENTIRY = SECTION = DESCRIPTION1 = @"";
	USER_KEY = STAFF_CL_KEY = RE_KEY = SITE_KEY = -1;
}

@end


@implementation LoginData

@synthesize loginName, password, Login;

-(void) RequestLoginData
{
    cout << "Request Login Data" << endl;
	NSString *request = [NSString stringWithFormat:@"EXEC int_User_Access '%@', 110", loginName];
	[AppDelegate.client executeQuery:request withDelegate:self];

/*
 EXEC int_User_Access 'MichaelH',110
 P1 = brugernavn
 P2= Application hvor 110 er Iphone app
 Du skal naturligvis tjekke
 PASSWRD  = med indtastet
 ACCESS_RIGHT = 1
 Du fÂr sÂÖ
 RE_KEY
 FULL NAME
 SITE_KEY
 SITE_NAME*/
}

- (id)init
{
	self=[super init];
    if (self)
		{
		Login = [[LoginDataContainer alloc] init];
		}
	return self;
}
-(void) Clear
{
	[Login clear];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
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
		
		NSInteger PASSWRD = [resultSet indexForField:@"PASSWRD"];
		NSInteger USERNAME = [resultSet indexForField:@"USERNAME"];
		NSInteger FULL_NAME = [resultSet indexForField:@"FULL_NAME"];
		NSInteger GROUP_NAME = [resultSet indexForField:@"GROUP_NAME"];
		NSInteger SITE_KEY = [resultSet indexForField:@"SITE_KEY"];
		NSInteger SITE_NAME = [resultSet indexForField:@"SITE_NAME"];
		NSInteger LEGAL_ENTIRY = [resultSet indexForField:@"LEGAL_ENTIRY"];
		NSInteger USER_KEY = [resultSet indexForField:@"USER_KEY"];
		NSInteger ACCESS_RIGHTS = [resultSet indexForField:@"ACCESS_RIGHTS"];
		NSInteger STAFF_CL_KEY = [resultSet indexForField:@"STAFF_CL_KEY"];
		NSInteger RE_KEY = [resultSet indexForField:@"RE_KEY"];
		NSInteger SECTION = [resultSet indexForField:@"SECTION"];
		NSInteger DESCRIPTION1 = [resultSet indexForField:@"DESCRIPTION1"];

		//PASSWRD USERNAME FULL_NAME GROUP_NAME SITE_KEY SITE_NAME LEGAL_ENTIRY USER_KEY ACCESS_RIGHTS STAFF_CL_KEY RE_KEY SECTION DESCRIPTION1 
		while ([resultSet moveNext])
			{
			try{
				[Login clear];
				Login.USER_KEY = [resultSet getInteger: USER_KEY ];
				Login.STAFF_CL_KEY = [ resultSet getInteger: STAFF_CL_KEY ];
				Login.RE_KEY = [ resultSet getInteger: RE_KEY ];
				Login.SITE_KEY = [ resultSet getInteger: SITE_KEY ];
				Login.ACCESS_RIGHTS = [ resultSet getInteger: ACCESS_RIGHTS ];

				Login.PASSWRD = [[resultSet getString:PASSWRD] retain];
				if ( ! [Login.PASSWRD isKindOfClass:[NSString class]])
					Login.PASSWRD=@"";
				Login.USERNAME = [[resultSet getString:USERNAME] retain];
				if ( ! [Login.USERNAME isKindOfClass:[NSString class]])
					Login.USERNAME=@"";
				Login.FULL_NAME = [[resultSet getString:FULL_NAME] retain];
				if ( ! [Login.FULL_NAME isKindOfClass:[NSString class]])
					Login.FULL_NAME=@"";
				Login.GROUP_NAME = [[resultSet getString:GROUP_NAME] retain];
				if ( ! [Login.GROUP_NAME isKindOfClass:[NSString class]])
					Login.GROUP_NAME=@"";
				Login.SITE_NAME = [[resultSet getString:SITE_NAME] retain];
				if ( ! [Login.SITE_NAME isKindOfClass:[NSString class]])
					Login.SITE_NAME=@"";
				Login.LEGAL_ENTIRY = [[resultSet getString:LEGAL_ENTIRY] retain];
				if ( ! [Login.LEGAL_ENTIRY isKindOfClass:[NSString class]])
					Login.LEGAL_ENTIRY=@"";
				Login.SECTION = [[resultSet getString:SECTION] retain];
				if ( ! [Login.SECTION isKindOfClass:[NSString class]])
					Login.SECTION=@"";
				Login.DESCRIPTION1 = [[resultSet getString:DESCRIPTION1] retain];
				if ( ! [Login.DESCRIPTION1 isKindOfClass:[NSString class]])
					Login.DESCRIPTION1=@"";
			} // try
			catch (NSException* ex)
				{
				DLog(@"doSomethingFancy failed: %@",ex);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"There was an error. Call Perry." message:ex.reason delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
				[alert release];
				} // catch
				
			} // while next
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		[AppDelegate.loginController LoginFailed];
		return;
	}
	
		// Did we get an account?
	if(Login.ACCESS_RIGHTS == 0)
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account don't exist. Or access is denieed." message:loginName delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		[AppDelegate.loginController LoginFailed];
		return;
		}
	
		// does the password match?
	DLog(@"Password: %@ supplied: %@", Login.PASSWRD, password);
	
	
	if ([password length] == 0)
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please supply a password." message:loginName delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		[AppDelegate.loginController LoginFailed];
		return;
		}
	
	if([Login.PASSWRD compare:password] == NSOrderedSame)// password OK
		{
		cout << "Done processing LoginData, password OK" << endl;
		[AppDelegate.loginController LoginOK];			// dismiss modal controller
		AppDelegate.loginOK=true;
		[AppDelegate RequestNextDataType];
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password error." message:loginName delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		[AppDelegate.loginController LoginFailed];
		}
}

@end
