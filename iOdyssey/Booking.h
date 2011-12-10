//
//  Booking.h
//  iSqlExample
//
//  Created by Michael Holm on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#pragma once

#include <string>
#include "Date.h"

using namespace std;

/*
 Date to number:
 NSDate *aDate = [NSDate date];
 NSNumber *secondsSinceRefDate = [NSNumber numberWithDouble:[aDate timeIntervalSinceReferenceDate]];
 Number to date:
 aDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[NSNumber doubleValue]];
*/

enum CStatus{ROS, BKS, BK, A16, A35, HL1, HL2, IO, CNI, CND, P01, NA, MET, TRA, SIP, GRATIS, INVOICED, UNKNOWN, ERROR};

enum PCODE{P_UNKNOWN, P_OPEN, P_FINISHED, P_APPROVED, P_PRECALC, P_PROFORMA, P_INVOICED, P_LOGGEDOUT, P_GRATIS, P_ERROR};


	//BK=Booking, BKS=Booking, supervised(m/kunder) HL1=First hold HL2=Second hold
	// Select * FROM Booking_slot_status
    
class Booking{
public:
    Booking()
    {
	BOKEYSELECTED=NO;
    }
	~Booking();
	
	bool IsSameAs(Booking &other);
	
	//Copy constructor
	Booking(const Booking &b);
	void CopyFrom(const Booking &b);
	
    void Print();
    void clear();
    
    bool overlaps(Booking &other);
    bool overlaps(Date &time);
	bool endsBefore(Date &time);
   
    // booking data
    NSString  *Resource;		// Visual Effects/ Colorist06
    int     RE_KEY;				// number
    CStatus STATUS;				// Hold, book, clients etc
    PCODE    pcode;				// Letter, O=Open(to be done), A=Actual(signed af), P=Proforma (Not invoiced), I=Invoiced, G=Gratis
    int    MTYPE;				// 1=Booking, 2=Hold, 
    int     BS_KEY;				// Booking slot key
    int     BO_KEY;				// Booking key
	bool	BOKEYSELECTED;		// highlight booking (not booking slot)
    NSString  *FIRST_NAME;		// Michael 
    NSString  *LAST_NAME;		// Holm
    NSString  *NAME;			// Proejct name
    NSString  *ACTIVITY;		// Online/CC/Effect
    NSString  *BK_Remark;		// remarks
    NSString  *Folder_name;		// Project
    NSString  *Folder_remark;	// info on project
    NSString  *TYPE;			// S=people | V=machines
    Date  FROM_TIME;
    Date  TO_TIME;
	NSString *CL_NAME;			// client name
	CGRect pickRectangle;
};

