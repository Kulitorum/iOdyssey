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


@implementation ClientInfo

@synthesize CL_KEY;
@synthesize CL_NAME;


- (id)init
{
    self = [super init];
    if (self)
		{
		}
    
    return self;
}

-(void) dealloc
{
	[CL_NAME release];
}

@end

@implementation ClientData


- (id)init
{
    self = [super init];
    if (self)
		{
		}
    
    return self;
}

-(void) dealloc
{
	[clients release];
	clients=nil;
}

-(ClientInfo*)GetClient:(int) CL_KEY
{
	for(int i=0;i<[clients count];i++)
		if( ((ClientInfo*)[clients objectAtIndex:i]).CL_KEY == CL_KEY)
			return [clients objectAtIndex:i];
	return [clients objectAtIndex:0];
}

-(ClientInfo*)GetClientByIndex:(int)index
{
	if(index >= [clients count])
		return nil;
	return [clients objectAtIndex:index];
}
-(int)Count
{
	return [clients count];
}

- (void)RequestClientData
{
    cout << "Request Client Data" << endl;
	
	NSString *request = [NSString stringWithFormat:@"select CL_KEY, CL_NAME FROM dbo.CLIENT WHERE ACCOUNT_CLOSED = 0 AND CL_ID > '' AND SITE_KEY = %d ORDER BY CL_NAME",AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	if(clients==nil)
		clients = [[NSMutableArray alloc] init];
	else
		[clients removeAllObjects];
	
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
				
				while ([resultSet moveNext])
					{
					ClientInfo *C = [[ClientInfo alloc] init];
					C.CL_KEY = [ resultSet getInteger: CL_KEY ];
					if(C.CL_KEY <= 0)
						continue;
					
					NSString *NAME = [resultSet getString: CL_NAME];
					if(NAME != nil && ([NAME isKindOfClass:[NSString class]] == YES))
						C.CL_NAME = [NAME retain];
					else
						{
						[C release];
						continue;
						}
					[clients addObject:C];
					[C release];
					}
				
				}
		ClientInfo *C = [[ClientInfo alloc] init];
		C.CL_KEY = 0;
		C.CL_NAME=@"[";
		[clients addObject:C];
		[C release];
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
