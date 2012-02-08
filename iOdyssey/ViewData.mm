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

/*********************************************************
 
 Resource
 
 *********************************************************/
@implementation Resource

@synthesize RE_NAME;
@synthesize RE_KEY;
@synthesize pickRectangle;
@synthesize selectRectangle;
@synthesize Unfolded;
@synthesize Selected;
@synthesize includeInNewBookingView;
@synthesize bookings;

-(id)initWithName:(NSString*)name ID:(int)ID
{
	self = [super init];
	if(self)
		{
		RE_NAME = [name retain];
		RE_KEY = ID;
		Unfolded = NO;
		Selected = NO;
		includeInNewBookingView=NO;
		bookings = [[NSMutableArray alloc] init];
		}
	return self;
}

-(id) init
{
	self = [super init];
	if(self)
		{
		Unfolded = NO;
		Selected = NO;
		includeInNewBookingView=NO;
		bookings = [[NSMutableArray alloc] init];
		}
	return self;
}

-(void) dealloc
{
	[RE_NAME release];
	[bookings removeAllObjects];
	[bookings release];
	bookings = nil;
}

-(void) deleteBookings
{
	if([bookings count] == 0)
		return;
	Booking*b = [bookings objectAtIndex:0];
	NSLog(@"Booking RT:%d", [b retainCount]);
	[bookings removeAllObjects];
	NSLog(@"Booking RT:%d", [b retainCount]);
}

-(void) sortBookingsByStartDate
{
//	NSArray *sortedArray = [[NSMutableArray alloc] init];
	NSArray* sortedArray = [bookings sortedArrayUsingSelector:@selector(startsEarlierThen:)];
	[bookings release];
	bookings = [sortedArray mutableCopy];
//	[sortedArray release];
//	[sortedArray release];
}

@end


/*********************************************************
 
 ViewData
 
 *********************************************************/
@implementation ViewData

@synthesize Resources;

-(id) init
{
	self = [super init];
	if(self)
		{
		Resources = [[NSMutableArray alloc] init];
		}
	return self;
}
-(void) Clear
{
	[self clearBookings];
	[Resources removeAllObjects];
}

-(void) clearBookings
{
	for(Resource *res in Resources)
		[res deleteBookings];
}

-(void) AddResource:(Resource*) other
{
	for (Resource *res in Resources)
		{
		if(res.RE_KEY == other.RE_KEY)
			return;
		}
	[Resources addObject:other];
}


-(void) AddBooking:(Booking*) book LOGGEDIN_RESOURCE_ID:(int)LOGGEDIN_RESOURCE_ID
{
	for (Resource *res in Resources)
		{
		if(book.RE_KEY == res.RE_KEY)
			{
			bool hasBooking=NO;
			for (Booking* b in res.bookings)
				{
				if(book.BS_KEY == b.BS_KEY)
					hasBooking=YES;
				}
			if(hasBooking == NO)
				{
				
				NSLog(@"RT1:%d", [book.Folder_remark retainCount]);
				[res.bookings addObject:book];
				NSLog(@"RT2:%d", [book.Folder_remark retainCount]);
				}
            return;
			}
		}
	NSLog(@"AddBooking : Resource not found : %@", book.Resource);
}
@end//ViewData
