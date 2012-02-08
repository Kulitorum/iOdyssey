//
//  Booking.cpp
//  iSqlExample
//
//  Created by Michael Holm on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include "Booking.h"
#include <iostream>
#include <sstream>
#include <string>
#include "iOdysseyAppDelegate.h"


@implementation Booking


@synthesize Resource;		// Visual Effects/ Colorist06
@synthesize RE_KEY;				// number
@synthesize STATUS;				// Hold, book, clients etc
@synthesize pcode;				// Letter, O=Open(to be done), A=Actual(signed af), P=Proforma (Not invoiced), I=Invoiced, G=Gratis
@synthesize MTYPE;				// 1=Booking, 2=Hold, 
@synthesize BS_KEY;				// Booking slot key
@synthesize BO_KEY;				// Booking key
@synthesize BOKEYSELECTED;		// highlight booking (not booking slot)
@synthesize FIRST_NAME;		// Michael 
@synthesize LAST_NAME;		// Holm
@synthesize NAME;			// Proejct name
@synthesize ACTIVITY;		// Online/CC/Effect
@synthesize BK_Remark;		// remarks
@synthesize Folder_name;		// Project
@synthesize Folder_remark;	// info on project
@synthesize TYPE;			// S=people | V=machines
@synthesize FROM_TIME;
@synthesize TO_TIME;
@synthesize CL_NAME;			// client name
@synthesize pickRectangle;


/*
-(void) Booking::clear()
{
    Resource=@"";
    RE_KEY=-1;
    STATUS=UNKNOWN;
    pcode=P_UNKNOWN;
    MTYPE=0;
    BS_KEY=-1;
		//    FROM_TIME = Date([NSDate date]);
		//    TO_TIME = [NSDate date];
    BO_KEY=-1;
    FIRST_NAME=@"";
    LAST_NAME=@"";
    NAME=@"";
	ACTIVITY=@"";
    BK_Remark=@"";
    Folder_name=@"";
    Folder_remark=@"";
    TYPE=@"";
	CL_NAME = @"";// client name
	pickRectangle=CGRectMake(0,0,0,0);
}
*/
-(void) Print
{
	DLog(@"%@\n%@\n",Resource, NAME);
	
/*    if (TYPE.find("S")!=string::npos)   // person
        cout << FIRST_NAME << " " << LAST_NAME << ": " << NAME << " Project " << Folder_name << " At " << FROM_TIME.m_hours << " to " << TO_TIME.m_hours << endl;
    else if (TYPE.find("V")!=string::npos)   // Machine
        cout << Resource << ": " << NAME << " Project " << Folder_name << " At " << FROM_TIME.m_hours << " to " << TO_TIME.m_hours << endl;
*/
}

-(bool) overlaps:(Booking*) other
{
    if( FROM_TIME.IsWithinRange(other.FROM_TIME, other.TO_TIME) || TO_TIME.IsWithinRange(other.FROM_TIME, other.TO_TIME) )
        return true;
    if( other.FROM_TIME.IsWithinRange(FROM_TIME, TO_TIME) || other.TO_TIME.IsWithinRange(FROM_TIME, TO_TIME) )
        return true;
	if(FROM_TIME.nstimeInterval() == other.FROM_TIME.nstimeInterval())
		return true;
	if(TO_TIME.nstimeInterval() == other.TO_TIME.nstimeInterval())
		return true;
    return false;
}

-(bool) overlapsDate:(Date) time
{
    if( time.IsWithinRange(FROM_TIME, TO_TIME) )
        return true;
	return false;
}

-(bool) endsBefore:(Date) time
{
    if( TO_TIME.nstimeInterval() < time.nstimeInterval() )
        return true;
	return false;
}
/*
void Booking::CopyFrom(const Booking &b)
{
	Resource = [[b.Resource copy] retain];
    RE_KEY = b.RE_KEY;
    STATUS = b.STATUS;
	pcode = b.pcode;
	MTYPE = b.MTYPE;
	BS_KEY = b.BS_KEY;
	BO_KEY = b.BO_KEY;
	FIRST_NAME = [[b.FIRST_NAME copy] retain];
	LAST_NAME = [[b.LAST_NAME copy] retain];
	NAME = [[b.NAME copy] retain];
	ACTIVITY = [[b.ACTIVITY copy] retain];
	BK_Remark = [[b.BK_Remark copy] retain];
	Folder_name = [[b.Folder_name copy] retain];
	Folder_remark = [[b.Folder_remark copy] retain];
	TYPE = [[b.TYPE copy] retain];
	FROM_TIME = b.FROM_TIME;
	TO_TIME = b.TO_TIME;
	CL_NAME = [[b.CL_NAME copy] retain];
	pickRectangle = b.pickRectangle;
	BOKEYSELECTED = b.BOKEYSELECTED;
}
*/
//Copy constructor
/*
Booking::Booking(const Booking &b)
{
	Resource = b.Resource;
    RE_KEY = b.RE_KEY;
    STATUS = b.STATUS;
	pcode = b.pcode;
	MTYPE = b.MTYPE;
	BS_KEY = b.BS_KEY;
	BO_KEY = b.BO_KEY;
	FIRST_NAME = b.FIRST_NAME;
	LAST_NAME = b.LAST_NAME;
	NAME = b.NAME;
	ACTIVITY=b.ACTIVITY;
	BK_Remark = b.BK_Remark;
	Folder_name = b.Folder_name;
	Folder_remark = b.Folder_remark;
	TYPE = b.TYPE;
	FROM_TIME = b.FROM_TIME;
	TO_TIME = b.TO_TIME;
	CL_NAME = b.CL_NAME;
	pickRectangle = b.pickRectangle;
	BOKEYSELECTED = NO;
}

-(bool) Booking::IsSameAs(Booking &other)
{
	if(STATUS != other.STATUS) { cout << "STATUS changed state" << endl ; return NO;}
	if(pcode != other.pcode) { cout << "pcode changed state" << endl ; return NO;}
	if(MTYPE != other.MTYPE) { cout << "MTYPE changed state" << endl ; return NO;}

	if(RE_KEY != other.RE_KEY) { cout << "RE_KEY changed state" << endl ; return NO;}
	if(BS_KEY != other.BS_KEY) { cout << "BS_KEY changed state" << endl ; return NO;}
	if(BO_KEY != other.BO_KEY) { cout << "BO_KEY changed state" << endl ; return NO;}
	
	if(FROM_TIME.nstimeInterval() != other.FROM_TIME.nstimeInterval()) 
		{ cout << "FROM_TIME changed state" << endl ; return NO;}
	if(TO_TIME.nstimeInterval() != other.TO_TIME.nstimeInterval()) 
		{ cout << "TO_TIME changed state" << endl ; return NO;}
	if ([Resource compare:other.Resource] != NSOrderedSame) 
		{ cout << "Resource changed state" << endl ; return NO;}
	if ([FIRST_NAME compare:other.FIRST_NAME] != NSOrderedSame) 
		{ cout << "FIRST_NAME changed state" << endl ; return NO;}
	if ([LAST_NAME compare:other.LAST_NAME] != NSOrderedSame) 
		{ cout << "LAST_NAME changed state" << endl ; return NO;}
	if ([NAME compare:other.NAME] != NSOrderedSame)
		{ cout << "NAME changed state" << endl ; return NO;}
	if ([ACTIVITY compare:other.ACTIVITY] != NSOrderedSame) 
		{ cout << "ACTIVITY changed state" << endl ; return NO;}
	if ([BK_Remark compare:other.BK_Remark] != NSOrderedSame) 
		{ cout << "BK_Remark changed state" << endl ; return NO;}
	if ([Folder_name compare:other.Folder_name] != NSOrderedSame) 
		{ cout << "Folder_name changed state" << endl ; return NO;}
	if ([Folder_remark compare:other.Folder_remark] != NSOrderedSame) 
		{ cout << "Folder_remark changed state" << endl ; return NO;}
	if ([TYPE compare:other.TYPE] != NSOrderedSame) 
		{ cout << "TYPE changed state" << endl ; return NO;}
	if ([CL_NAME compare:other.CL_NAME] != NSOrderedSame) 
		{ cout << "CL_NAME changed state" << endl ; return NO;}

	return YES;
}
*/
-(void) dealloc
{
    // booking data
    [Resource release];		// Visual Effects/ Colorist06
    [FIRST_NAME release];	// Michael 
    [LAST_NAME release];	// Holm
    [NAME release];			// Proejct name
    [ACTIVITY release];		// Online/CC/Effect
    [BK_Remark release];	// remarks
    [Folder_name release];	// Project
    [Folder_remark release];// info on project
    [TYPE release];			// S=people | V=machines
	[CL_NAME release];		// client name
}

- (NSComparisonResult)startsEarlierThen:(Booking *)otherObject
{
    return FROM_TIME.nstimeInterval() < otherObject.FROM_TIME.nstimeInterval();
}


@end








