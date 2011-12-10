 //
//  Date.cpp
//  iOdyssey
//
//  Created by Michael Holm on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Date.h"
#include <iostream>
#include <sstream>
#include <iomanip>
#include "iOdysseyAppDelegate.h"

// Constructors

Date::Date()
{
    referenceTime=0;
}

Date::Date(NSString *date)
{
//	NSString *hackedString = [date stringByReplacingOccurrencesOfString:@"+0000" withString:@"+0200"];
    NSDate *theDate = [AppDelegate.formatter dateFromString:date]; //2011-01-02 09:00:00 +0000
	referenceTime = [theDate timeIntervalSinceReferenceDate];
}

Date::Date (NSDate *date)
{
    referenceTime = [date timeIntervalSinceReferenceDate];
}

Date::Date(NSTimeInterval time)
{
    referenceTime=time;
}

// As NSDate

NSDate *Date::nsdate()
{
	return [NSDate dateWithTimeIntervalSinceReferenceDate:referenceTime];
}

NSTimeInterval Date::nstimeInterval() const	// The time in seconds (double seconds, that is)
{
    return referenceTime;
}

bool Date::isWeekend()
{
	NSDate *aDate = nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
	NSRange weekdayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];
	NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:aDate];
	NSUInteger weekdayOfDate = [components weekday];
	
	if (weekdayOfDate == weekdayRange.location || weekdayOfDate == weekdayRange.length)
		{
		return YES;
		}
	return NO;
}
// Compare dates
bool Date::IsSameDayAs(Date date)
{
    // faster version
    long a=(long)referenceTime;
    long aa = a-(a%86400);
    long b=(long)date.nstimeInterval();
    long bb = b-(b%86400);
    
    return bb==aa;
	
    NSDate *thisDate = nsdate();
    NSDate *otherDate = date.nsdate();
	
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:thisDate];
    NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:otherDate];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

int Date::daysBetweenDate(Date date)
{
    NSDate *fromDateTime = nsdate();
    NSDate *toDateTime = date.nsdate();

    NSDate *fromDate;
    NSDate *toDate;

	NSCalendar *calendar = AppDelegate.calendar;
	
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDateTime];
	
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
	
    return [difference day];
}


bool Date::IsEarlierThen(Date date)
{
    return referenceTime<date.nstimeInterval();
}

bool Date::IsLaterThen(Date date)
{
    return referenceTime>date.nstimeInterval();
}


// relative functions

Date Date::DaysBefore(int days)
{
    return Date(referenceTime - 24*60*60*days);
}
Date Date::HoursBefore(int hours)
{
    return Date(referenceTime - 60*60*hours);
}
Date Date::MinutesBefore(int minutes)
{
    return Date(referenceTime - 60*minutes);
}

Date Date::DaysAfter(int days)
{
    return Date(referenceTime + 24*60*60*days);
}
Date Date::HoursAfter(int hours)
{
    return Date(referenceTime + 60*60*hours);
}
Date Date::MinutesAfter(int minutes)
{
    return Date(referenceTime + 60*minutes);
}


Date Date::After(int days, int hours, int minutes)
{
    return Date(referenceTime + 60*minutes + 3600*hours + 86400*days);
}
Date Date::Before(int days, int hours, int minutes)
{
    return Date(referenceTime - (60*minutes + 3600*hours + 86400*days));
}

Date Date::ClosestQuarter()
{
	referenceTime+= 30*15;
    return Date(referenceTime - (((int)referenceTime)%(60*15)));
}

// output

string Date::str()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:d];
    ostringstream oss;
	
    oss << [components1 year] <<"-"<< setw(2) << setfill('0') << [components1 month] <<"-" <<  setw(2) << setfill('0') << [components1 day] <<" "<<  setw(2) << setfill('0') << [components1 hour] <<":" <<  setw(2) << setfill('0') << [components1 minute] << ":" <<  setw(2) << setfill('0') << [components1 second];
    return oss.str();
}

NSString *Date::NSStr()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:d];
	
	return [NSString stringWithFormat:@"%d-%02d-%-2d %02d:%02d", [components1 year], [components1 month], [components1 day],  [components1 hour], [components1 minute]];
}

// Monday 24 October
NSString *Date::FormatForMyBookings()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSMonthCalendarUnit | NSDayCalendarUnit | kCFCalendarUnitWeekday) fromDate:d];
	
	NSString *dayname;
	switch( [components1 weekday])
	{
		case 1:	dayname=@"Sunday"; break;
		case 2:	dayname=@"Monday"; break;//Sø
		case 3:	dayname=@"Tuesday"; break;
		case 4:	dayname=@"Wedensday"; break;
		case 5:	dayname=@"Thursday"; break;
		case 6:	dayname=@"Friday"; break;
		case 7:	dayname=@"Saturday"; break;
		default: dayname=@"Bug"; break;
	}
	NSString *monthname;
	switch( [components1 month])
	{
		case 1:	monthname=@"Janury"; break;
		case 2:	monthname=@"Febury"; break;
		case 3:	monthname=@"Marts"; break;
		case 4:	monthname=@"April"; break;
		case 5:	monthname=@"May"; break;
		case 6:	monthname=@"june"; break;
		case 7:	monthname=@"Juli"; break;
		case 8:	monthname=@"August"; break;
		case 9:	monthname=@"September"; break;
		case 10:monthname=@"October"; break;
		case 11:monthname=@"November"; break;
		case 12:monthname=@"December"; break;
		default: monthname=@"Bug"; break;
	}
	return [NSString stringWithFormat:@"%@ %0d %@", dayname, [components1 day], monthname];
}


NSString *Date::FormatForGanttView(bool includeYear)
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | kCFCalendarUnitWeekday) fromDate:d];
	//weekdayOrdinal/weekday
	NSString *dayname;
	switch( [components1 weekday])
	{
		case 1:	dayname=@"Sun"; break;
		case 2:	dayname=@"Mon"; break;//Sø
		case 3:	dayname=@"Tue"; break;
		case 4:	dayname=@"Wed"; break;
		case 5:	dayname=@"Thu"; break;
		case 6:	dayname=@"Fri"; break;
		case 7:	dayname=@"Sat"; break;
		default: dayname=@"Bug"; break;
	}
	string monthname;
	if(includeYear)
		return [NSString stringWithFormat:@"%@ %02d-%02d-%d", dayname, [components1 day], [components1 month], [components1 year] ];
	
	return [NSString stringWithFormat:@"%@ %02d-%02d", dayname, [components1 day], [components1 month]];
}

NSString *Date::FormatForSignOffController()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:d];
	//weekdayOrdinal/weekday
	NSString *dayname;
	switch( [components1 weekday])
	{
		case 1:	dayname=@"Sun"; break;
		case 2:	dayname=@"Mon"; break;//Sø
		case 3:	dayname=@"Tue"; break;
		case 4:	dayname=@"Wed"; break;
		case 5:	dayname=@"Thu"; break;
		case 6:	dayname=@"Fri"; break;
		case 7:	dayname=@"Sat"; break;
		default: dayname=@"Bug"; break;
	}
	return [NSString stringWithFormat:@"%@ %02d-%02d %02d:%02d", dayname, [components1 day], [components1 month], components1.hour, components1.minute];
}

NSString *Date::FormatForNewBooking()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:( kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:d];
	return [NSString stringWithFormat:@"%02d:%02d", components1.hour, components1.minute];
}

NSString *Date::FormatForUpdatedLabel()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:d];

	NSDate *a=[NSDate date];
	Date today(a);

	if ( IsSameDayAs(today.DaysBefore(1))) // Yesterday
		return @"Updated Yesterday";
	if( IsEarlierThen(today.DaysBefore(1))) // date
	   return [NSString stringWithFormat:@"Updated  %02d-%02d ", [components1 day], [components1 month]];

	return [NSString stringWithFormat:@"Updated Today %02d:%02d", components1.hour, components1.minute];
}


NSString *Date::FormatForAddCommentView()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:d];
		//weekdayOrdinal/weekday
	NSString *dayname;
	switch( [components1 weekday])
	{
		case 1:	dayname=@"Sun"; break;
		case 2:	dayname=@"Mon"; break;//Sø
		case 3:	dayname=@"Tue"; break;
		case 4:	dayname=@"Wed"; break;
		case 5:	dayname=@"Thu"; break;
		case 6:	dayname=@"Fri"; break;
		case 7:	dayname=@"Sat"; break;
		default: dayname=@"Bug"; break;
	}
	return [NSString stringWithFormat:@"%@ %02d-%02d %02d:%02d", dayname, [components1 day], [components1 month], components1.hour, components1.minute];
}

NSString *Date::FormatForSQLWithTime()	//2011-01-01 10:00
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:d];
    return [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d", [components1 year], [components1 month], [components1 day] , [components1 hour], [components1 minute]];
}

NSString *Date::FormatForSQL()
{
    NSDate *d=nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:d];
	//2011-02-23
    return [NSString stringWithFormat:@"%d-%02d-%02d", [components1 year], [components1 month], [components1 day]];
}
float Date::HourValueAsFloat()
{
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components = [calendar components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:nsdate()];

    return ((float)[components hour] + ((float)[components minute]/60.0f));
}

int Date::HourValue()
{
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components = [calendar components:(NSHourCalendarUnit) fromDate:nsdate()];
    return ([components hour]);
}
int Date::YearValue()
{
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit) fromDate:nsdate()];
    return ([components year]);
}

NSString *Date::MonthValue()
{
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:NSMonthCalendarUnit fromDate:nsdate()];
	
	NSString *monthname;
	switch( [components1 month])
	{
		case 1:	monthname=@"Janury"; break;
		case 2:	monthname=@"Febury"; break;
		case 3:	monthname=@"Marts"; break;
		case 4:	monthname=@"April"; break;
		case 5:	monthname=@"May"; break;
		case 6:	monthname=@"june"; break;
		case 7:	monthname=@"Juli"; break;
		case 8:	monthname=@"August"; break;
		case 9:	monthname=@"September"; break;
		case 10:monthname=@"October"; break;
		case 11:monthname=@"November"; break;
		case 12:monthname=@"December"; break;
		default: monthname=@"Bug"; break;
	}

    return [NSString stringWithFormat:@"%@", monthname];
}

NSString* Date::FormatForDataScopeView()
{
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* components1 = [calendar components:(NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:nsdate()];
	
	NSString *monthname;
	switch( [components1 month])
	{
		case 1:	monthname=@"Janury"; break;
		case 2:	monthname=@"Febury"; break;
		case 3:	monthname=@"Marts"; break;
		case 4:	monthname=@"April"; break;
		case 5:	monthname=@"May"; break;
		case 6:	monthname=@"june"; break;
		case 7:	monthname=@"Juli"; break;
		case 8:	monthname=@"August"; break;
		case 9:	monthname=@"September"; break;
		case 10:monthname=@"October"; break;
		case 11:monthname=@"November"; break;
		case 12:monthname=@"December"; break;
		default: monthname=@"Bug"; break;
	}
	
    return [NSString stringWithFormat:@"%@ %dth", monthname, [components1 day ]];
}

Date Date::StartOfDay()
{
    NSDate *d= nsdate();
	NSCalendar *calendar = AppDelegate.calendar;
    NSDateComponents* dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:d];
	
	NSDate *newDate = [calendar dateFromComponents:dateComponents];
	return Date(newDate);
}

Date Date::Midtday()
{
	return StartOfDay().HoursAfter(12);
}

bool Date::IsWithinRange(Date start, Date end)
{
    if(nstimeInterval() > start.nstimeInterval() && referenceTime < end.nstimeInterval())
        return true;
    return false;
}






























