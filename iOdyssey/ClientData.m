//
//  ClientData.m
//  iOdyssey
//
//  Created by Michael Holm on 05/10/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

#import "ClientData.h"
#import "iOdysseyAppDelegate.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"

@implementation ClientData


- (id)init
{
    self = [super init];
    if (self)
		{
		}
    
    return self;
}
-(ClientInfo*)GetClient:(int) CL_KEY
{
	for(int i=0;i<clients.size();i++)
		if(clients[i].CL_KEY == CL_KEY)
			return &clients[i];
	return &clients[0];
}

-(ClientInfo*)GetClientByIndex:(int)index
{
	if(index >= clients.size())
		return nil;
	return &clients[index];
}
-(int)Count
{
	return clients.size();
}

- (void)RequestClientData
{
    cout << "Request Client Data" << endl;
	
	NSString *request = [NSString stringWithFormat:@"select CL_KEY, CL_NAME FROM dbo.CLIENT WHERE ACCOUNT_CLOSED = 0 AND CL_ID > '' AND SITE_KEY = %d ORDER BY CL_NAME",AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	cout << "Got Client Data, Processing" << endl;
	//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
			for (SqlResultSet *resultSet in query.resultSets)
				{
/*				for (int i = 0; i < resultSet.fieldCount; i++)
					{
					[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
					}
				[outputString appendString:@"\r\n--------\r\n"];
				
*/				
				NSInteger CL_KEY = [resultSet indexForField:@"CL_KEY"];
				NSInteger CL_NAME = [resultSet indexForField:@"CL_NAME"];
				
				ClientInfo C;
				
				while ([resultSet moveNext])
					{
					C.CL_KEY = [ resultSet getInteger: CL_KEY ];
					if(C.CL_KEY <= 0)
						continue;
					
					NSString *NAME = [resultSet getString: CL_NAME];
					if(NAME != nil && ([NAME isKindOfClass:[NSString class]] == YES))
						C.CL_NAME = [NAME retain];
					else
						continue;
					clients.push_back(C);
					}
				
				}
		ClientInfo C;
		C.CL_KEY = 0;
		C.CL_NAME=@"[";
		clients.push_back(C);// end of AA
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
	[AppDelegate RequestNextDataType];
}

@end
