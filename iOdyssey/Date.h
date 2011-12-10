//
//  Date.h
//  iOdyssey
//
//  Created by Michael Holm on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#pragma once

#include <string>
//#include "NSDate-Utilities.h"
#import <Foundation/Foundation.h>

using namespace std;


class Date
{
public:
    Date();
    Date(NSString *date);
    Date(NSDate *date);
    Date(NSTimeInterval time);
    
    // conversion
    NSDate *nsdate();
    NSTimeInterval nstimeInterval() const;
    // compare
    bool IsSameDayAs(Date date);
    bool IsEarlierThen(Date date);
    bool IsLaterThen(Date date);
    // relative
    Date DaysBefore(int days);
    Date HoursBefore(int hours);
	Date MinutesBefore(int minutes);
    Date DaysAfter(int days);
    Date HoursAfter(int hours);
	Date MinutesAfter(int minutes);
    Date After(int days, int hours, int minutes);
    Date Before(int days, int hours, int minutes);
    int HourValue();
    int YearValue();
	float HourValueAsFloat();
	NSString *MonthValue();
	Date Midtday();
	Date StartOfDay();
	Date ClosestQuarter();

    bool IsWithinRange(Date start, Date end);
	int daysBetweenDate(Date date);
	bool isWeekend();
    
    Date operator-(Date other){return referenceTime-other.nstimeInterval();}
    Date operator+(Date other){return referenceTime+other.nstimeInterval();}
    
    string str();
    NSString *NSStr();
	NSString *FormatForGanttView(bool includeYear=false);
	NSString *FormatForSQL();
	NSString *FormatForSQLWithTime();
	NSString *FormatForSignOffController();
	NSString *FormatForAddCommentView();
	NSString *FormatForUpdatedLabel();
	NSString *FormatForMyBookings();
	NSString *FormatForDataScopeView();
	NSString *FormatForNewBooking();
    
private:
    NSTimeInterval referenceTime;
};