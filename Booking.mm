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
@synthesize RE_KEY;			// number
@synthesize STATUS;			// Hold, book, clients etc
@synthesize pcode;			// Letter, O=Open(to be done), A=Actual(signed af), P=Proforma (Not invoiced), I=Invoiced, G=Gratis
@synthesize MTYPE;			// 1=Booking, 2=Hold,
@synthesize BS_KEY;			// Booking slot key
@synthesize BO_KEY;			// Booking key
@synthesize BOKEYSELECTED;	// highlight booking (not booking slot)
@synthesize FIRST_NAME;		// Michael 
@synthesize LAST_NAME;		// Holm
@synthesize NAME;			// Proejct name
@synthesize ACTIVITY;		// Online/CC/Effect
@synthesize BK_Remark;		// remarks
@synthesize Folder_name;	// Project
@synthesize Folder_remark;	// info on project
@synthesize TYPE;			// S=people | V=machines
@synthesize FROM_TIME;
@synthesize TO_TIME;
@synthesize CL_NAME;		// client name
@synthesize PR_NAME;
@synthesize PR_ID;
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

-(id) init
{
	self = [super init];
	if(self)
		{
		Resource=FIRST_NAME=LAST_NAME=NAME=ACTIVITY=BK_Remark=Folder_name=Folder_remark=TYPE=CL_NAME=nil;
		}
	return self;
}

-(void) checkIntegrity
{
	if(Resource==nil || ![Resource isKindOfClass:[NSString class]])
		Resource=@"";
	if(FIRST_NAME==nil || ![FIRST_NAME isKindOfClass:[NSString class]])
		FIRST_NAME=@"";
	if(LAST_NAME==nil || ![LAST_NAME isKindOfClass:[NSString class]])
		LAST_NAME=@"";
	if(NAME==nil || ![NAME isKindOfClass:[NSString class]])
		NAME=@"";
	if(ACTIVITY==nil || ![ACTIVITY isKindOfClass:[NSString class]])
		ACTIVITY=@"";
	if(BK_Remark==nil || ![BK_Remark isKindOfClass:[NSString class]])
		BK_Remark=@"";
	if(Folder_name==nil || ![Folder_name isKindOfClass:[NSString class]])
		Folder_name=@"";
	if(Folder_remark==nil || ![Folder_remark isKindOfClass:[NSString class]])
		Folder_remark=@"";
	if(TYPE==nil || ![TYPE isKindOfClass:[NSString class]])
		TYPE=@"";
	if(CL_NAME==nil || ![CL_NAME isKindOfClass:[NSString class]])
		CL_NAME=@"";
}


- (NSComparisonResult)startsEarlierThen:(Booking *)otherObject
{
    return FROM_TIME.nstimeInterval() > otherObject.FROM_TIME.nstimeInterval();
}

-(Date*) fromTimePtr
{
	return &FROM_TIME;
}
-(Date*) toTimePtr
{
	return &TO_TIME;
}


@end








