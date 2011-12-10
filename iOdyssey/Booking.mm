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
/*
 string Resource;        // Visual Effects/ Colorist06
 int     ResourceKey;    // number
 CStatus STATUS;     // Hold, book, clients etc
 bool    PCODE;      //?
 int    MTYPE;      //?
 int     BS_KEY;     //?
 Time FROM_TIME;
 Time TO_TIME;
 int     BO_KEY;
 string  FIRST_NAME; // Michael Holm
 string  LAST_NAME;  // unused, alwasy <null>
 string  NAME;       // Online/CC/Effect
 string  BK_Remark;  // remarks
 string  Folder_name; // Project
 string  Folder_remark;// info on project
 string  TYPE;        // S=people | V=machines
 */

void Booking::clear()
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

void Booking::Print()
{
	DLog(@"%@\n%@\n",Resource, NAME);
	
/*    if (TYPE.find("S")!=string::npos)   // person
        cout << FIRST_NAME << " " << LAST_NAME << ": " << NAME << " Project " << Folder_name << " At " << FROM_TIME.m_hours << " to " << TO_TIME.m_hours << endl;
    else if (TYPE.find("V")!=string::npos)   // Machine
        cout << Resource << ": " << NAME << " Project " << Folder_name << " At " << FROM_TIME.m_hours << " to " << TO_TIME.m_hours << endl;
*/
}

bool Booking::overlaps(Booking &other)
{
    if( FROM_TIME.IsWithinRange(other.FROM_TIME, other.TO_TIME) || TO_TIME.IsWithinRange(other.FROM_TIME, other.TO_TIME) )
        return true;
    if( other.FROM_TIME.IsWithinRange(FROM_TIME, TO_TIME) || other.TO_TIME.IsWithinRange(FROM_TIME, TO_TIME) )
        return true;
	if(FROM_TIME.nstimeInterval() == other.FROM_TIME.nstimeInterval())
		return true;
	if(TO_TIME.nstimeInterval() == other.TO_TIME.nstimeInterval())
		return true;
/*	if(FROM_TIME.nstimeInterval() == other.TO_TIME.nstimeInterval())
		return true;
	if(TO_TIME.nstimeInterval() == other.FROM_TIME.nstimeInterval())
		return true;
*/	
    return false;
}

bool Booking::overlaps(Date &time)
{
    if( time.IsWithinRange(FROM_TIME, TO_TIME) )
        return true;
	return false;
}

bool Booking::endsBefore(Date &time)
{
    if( TO_TIME.nstimeInterval() < time.nstimeInterval() )
        return true;
	return false;
}

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

//Copy constructor
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

bool Booking::IsSameAs(Booking &other)
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

Booking::~Booking()
{
}











