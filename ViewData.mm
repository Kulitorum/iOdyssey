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
		RE_NAME = name;
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
	[bookings removeAllObjects];
}

-(void) deleteBookings
{
	if([bookings count] == 0)
		return;
	[bookings removeAllObjects];
}

-(void) sortBookingsByStartDate
{
//	NSArray *sortedArray = [[NSMutableArray alloc] init];
	NSArray* sortedArray = [bookings sortedArrayUsingSelector:@selector(startsEarlierThen:)];
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
				[res.bookings addObject:book];
				}
            return;
			}
		}
	NSLog(@"AddBooking : Resource not found : %@", book.Resource);
}
@end//ViewData
