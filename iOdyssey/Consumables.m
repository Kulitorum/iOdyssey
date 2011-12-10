//
//  Consumables.m
//  iOdyssey
//
//  Created by Kulitorum on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Consumables.h"
#import "iOdysseyAppDelegate.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"

@implementation Consumable
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

@end

@implementation SCG
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

@end

@implementation Consumables

@synthesize items;
@synthesize Ready;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}


- (void)RequestConsumableData:(int)BO_KEY;
{
	Ready = NO;
    cout << "Request Consumable Data" << endl;

//    EXEC dbo.IOS_UPDATE_BK_REMARK
    
	NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_BOOKING_SC_LIST @BO_KEY=%d, @SITE_KEY = %d",BO_KEY, AppDelegate->loginData.Login.SITE_KEY];
	//	NSString *request = [NSString stringWithFormat:@"SELECT * FROM dbo.FS_SERVICE_CODE WHERE SERVICE=2 AND SITE_KEY = %d AND IS_CURRENT=1",AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
	
	//	[AppDelegate.client executeQuery:@"SELECT * FROM dbo.FS_SERVICE_CODE WHERE SERVICE=2;" withDelegate:self];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	//SC_KEY SC_NAME IS_CURRENT SITE_KEY UNIT SC_ID BO_KEY PI_NAME 

	ServiceGroups = [[NSMutableArray arrayWithCapacity: 2] retain];
	
	cout << "Got Consumable Data, Processing" << endl;
	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
			for (int i = 0; i < resultSet.fieldCount; i++)
				{
				[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
				}
			[outputString appendString:@"\r\n--------\r\n"];
			
			DLog(@"%@",outputString );
			
			NSInteger SC_KEY = [resultSet indexForField:@"SC_KEY"];
			NSInteger SC_NAME = [resultSet indexForField:@"SC_NAME"];
			NSInteger UNIT = [resultSet indexForField:@"UNIT"];
			NSInteger SCG_NAME = [resultSet indexForField:@"SCG_NAME"];
			NSInteger SCG_KEY = [resultSet indexForField:@"SCG_KEY"];
			NSInteger QTY = [resultSet indexForField:@"QTY"];
			
			while ([resultSet moveNext])
				{
				Consumable *C = [[Consumable alloc] init];
				SCG *S = [[SCG alloc] init];
				C->SC_KEY  = [resultSet getInteger: SC_KEY ];
				C->SC_NAME = [[resultSet getString: SC_NAME] retain];
				C->UNIT    = [[resultSet getString: UNIT] retain];
				C->SCG_KEY    = [resultSet getInteger: SCG_KEY];
				C->QTY = C->newQTY = [resultSet getInteger:QTY];
				S->SCG_KEY = C->SCG_KEY;
				// Do we have this key?
				bool HasIt = NO;
				for(int i=0;i<[ServiceGroups count];i++)
					if(((SCG*)[ServiceGroups objectAtIndex:i])->SCG_KEY == S->SCG_KEY)
						{
						HasIt = YES;
						[((SCG*)[ServiceGroups objectAtIndex:i])->items addObject:C];
						break;
						}
				if(HasIt == NO)
					{
					S->SCG_NAME = [[resultSet getString: SCG_NAME] retain];
					[ServiceGroups addObject:S];
					((SCG*)[ServiceGroups objectAtIndex:([ServiceGroups count]-1)])->items = [[NSMutableArray arrayWithCapacity: 2] retain];
					[((SCG*)[ServiceGroups objectAtIndex:([ServiceGroups count]-1)])->items addObject:C];
					}
				else
					[S release];
				[items addObject:C];
				}
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		}
/*
	NSEnumerator * S = [ServiceGroups objectEnumerator];
	SCG* s;
	
	while(s = [S nextObject])
		{
		NSEnumerator * I = [items objectEnumerator];
		Consumable* i;
		while(i = [I nextObject])
			if(i->SCG_KEY == s->SCG_KEY)
				s->count++;
		}
*/	
	//	[AppDelegate RequestNextDataType];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ConsumablesReadyNotification" object:self];
	Ready=YES;
	DLog(@"%@", outputString);
}

- (void)dealloc
{
	for(int i=0;i< [items count];i++)
		{
		Consumable* asd = (Consumable*)[items objectAtIndex:i];
		[asd->SC_NAME release];
		[asd->UNIT release];
		}
	[items release];
}
@end
