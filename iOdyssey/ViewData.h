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
class Resource{
public:
	Resource(){};
    Resource(NSString *ResourceName, int KEY)
    {
	RE_NAME = [ResourceName copy];
	RE_KEY=KEY;
	Unfolded = NO;
	Selected = NO;
	includeInNewBookingView=NO;
    }
    NSString *RE_NAME;
    int RE_KEY;

    void DeleteBookings()  { bookings.clear(); }
	CGRect pickRectangle;
	CGRect selectRectangle;
	bool Unfolded;
	bool Selected;
	bool includeInNewBookingView;
    vector<Booking> bookings;
};

class ViewData
{
public:  
    ViewData(){};
    void Clear(){
        for(size_t i=0;i<Resources.size();i++)
            Resources[i].DeleteBookings();
    }
	
    void AddResource(Resource &res)
	{
	for(size_t i=0;i<Resources.size();i++)
        {
		if(res.RE_KEY == Resources[i].RE_KEY)
			return;	// And thereby not to add it
		}
	Resources.push_back(res);
	}
	
	
    void AddBooking(Booking &book, int LOGGEDIN_RESOURCE_ID)
    {
        for(size_t i=0;i<Resources.size();i++)
        {
            if(book.RE_KEY == Resources[i].RE_KEY)
            {
			bool hasBooking=NO;
			for(int x=0;x<Resources[i].bookings.size();x++)
				if(Resources[i].bookings[x].BS_KEY == book.BS_KEY)
					hasBooking = YES;
			if(hasBooking == NO)
				Resources[i].bookings.push_back(book);
            return;
            }
        }
		cout << "AddBooking : Resource not found : " << [book.Resource UTF8String] << endl;
    }
    vector<Resource> Resources;
};


@interface ViewDataController : NSObject <SqlClientDelegate>
{
	NSTimer *timer;
}

-(void) RefreshMyBookings;
-(void) start;

@end














