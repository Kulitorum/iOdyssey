//
//  ViewData.h
//  iOdyssey
//
//  Created by Michael Holm on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#pragma once

#import <UIKit/UIKit.h>
#include <string>
#include <vector>
#import "SqlClient.h"
#include "Booking.h"
#include <iostream>

using namespace std;
/*
 RE_KEY SRT_ORDER HEADER_TXT ITEM_TYPE RE_NAME START_DAY LEAVE_DAY GENERIC SITE_KEY IS_CURRENT 
--------
33 | 101 | 1 | <null> | 0 | Flame / Nuke | 1999-03-01 00:00:00 +0000 | 2015-12-31 00:00:00 +0000 | 0 | 9999 | 1 | 
33 | 102 | 2 | <null> | 0 | Flame  | 1999-03-01 00:00:00 +0000 | 2015-12-31 00:00:00 +0000 | 0 | 9999 | 1 | 
33 | 104 | 3 | <null> | 0 | Nuke 2 | 2009-09-01 00:00:00 +0000 | 2015-12-31 00:00:00 +0000 | 0 | 9999 | 1 | 
*/

/*********************************************************
 
 Resource
 
 *********************************************************/

@interface Resource : NSObject
{
    NSString *RE_NAME;
    int RE_KEY;
	CGRect pickRectangle;
	CGRect selectRectangle;
	bool Unfolded;
	bool Selected;
	bool includeInNewBookingView;
    NSMutableArray *bookings;
};

@property (nonatomic) NSString *RE_NAME;
@property int RE_KEY;
@property CGRect pickRectangle;
@property CGRect selectRectangle;
@property bool Unfolded;
@property bool Selected;
@property bool includeInNewBookingView;
@property (nonatomic) NSMutableArray *bookings;

-(void) deleteBookings;
-(id)initWithName:(NSString*)name ID:(int)ID;
-(void) sortBookingsByStartDate;

@end

/*********************************************************
 
 ViewData
 
 *********************************************************/

@interface ViewData : NSObject
{
	NSMutableArray *Resources;
};

@property (nonatomic) NSMutableArray *Resources;

-(void) AddResource:(Resource*) other;
-(void) AddBooking:(Booking*) book LOGGEDIN_RESOURCE_ID:(int)LOGGEDIN_RESOURCE_ID;
-(void) clearBookings;
-(void) Clear;
@end














