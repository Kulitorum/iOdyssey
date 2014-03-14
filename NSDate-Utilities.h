#pragma once

#import <Foundation/Foundation.h>

/*
 NSDate *dateToCheck;
 NSDate *dateRangeStart;
 NSDate *dateRangeEnd;
 
 BOOL isBetween = [dateToCheck isBetween:dateRangeStart :dateRangeEnd];
 */

@interface NSDate (Utilities)

- (BOOL)isBetween:(NSDate *)dateStart:(NSDate *)dateEnd;
- (BOOL)isSameDay:(NSDate*)anotherDate;
- (BOOL)isToday;
- (BOOL)isYesterday;
- (BOOL)isLastWeek;
- (NSString *)stringFromDateCapitalized:(BOOL)capitalize;

- (NSDate *)dateByAddingHours:(NSInteger) hours;
- (NSDate*)dateByAddingDays:(NSInteger) days;
- (BOOL)isEarlierThanDate:(NSDate *) otherDate;

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

@end
