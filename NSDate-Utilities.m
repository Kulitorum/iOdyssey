

#import "NSDate-Utilities.h"

static NSCalendar *calendar;
static NSDateFormatter *displayFormatter;

//@implementation NSDate (Helper)

@implementation NSDate (Utilities)

- (BOOL)isBetween:(NSDate *)dateStart:(NSDate *)dateEnd
{
	if ([self compare:dateEnd] == NSOrderedDescending)
		return NO;
	
	if ([self compare:dateStart] == NSOrderedAscending) 
		return NO;
	
	return YES;
}

- (BOOL)isSameDay:(NSDate*)anotherDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (BOOL)isToday
{
    return [self isSameDay:[NSDate date]];
}

- (BOOL)isYesterday
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    NSDate *yesterday = [calendar dateByAddingComponents:comps toDate:[NSDate date]  options:0];
    [comps release];
    return [self isSameDay:yesterday];    
}

- (NSDate*)dateByAddingHours:(NSInteger) hours
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:hours];
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:[NSDate date]  options:0];
    [comps release];
    return newDate;    
}

- (NSDate*)dateByAddingDays:(NSInteger) days
{
    return [self dateByAddingDays:days*24];    
}

- (BOOL)isLastWeek
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSWeekCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date] toDate:self options:0];
    NSInteger week = [comps week];
    NSInteger days = [comps day];
    return (0==week && days<=0);
}

- (BOOL)isEarlierThanDate:(NSDate *) otherDate
{
    return false;
}

- (NSString *)stringFromDateCapitalized:(BOOL)capitalize
{
    NSString *label = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormatPrefix = nil;
    
    [dateFormatter setDateStyle:NSDateFormatterNoStyle]; // Will display hour only, we are building the day ourselves
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if([self isToday])
        {
        if(capitalize) dateFormatPrefix = NSLocalizedString(@"Today at", @"");
        else dateFormatPrefix = NSLocalizedString(@"today at", @"");
        }
    else if([self isYesterday])
        {
        if(capitalize) dateFormatPrefix = NSLocalizedString(@"Yesterday at", @"");
        else dateFormatPrefix = NSLocalizedString(@"yesterday at", @"");
        }
    else if([self isLastWeek])
        {
        NSDateFormatter *weekDayFormatter = [[NSDateFormatter alloc] init];
        
        // We will set the locale to US to have the weekday in english.
        // The NSLocalizedString(weekDayString, @"") below will make it localized.
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [weekDayFormatter setLocale:locale];
        [locale release];
        [weekDayFormatter setDateFormat:@"EEEE"];
        NSString *weekDayString = [NSString stringWithFormat:@"%@ at", [weekDayFormatter stringFromDate:self]];
        dateFormatPrefix = NSLocalizedString(weekDayString, @"");
        [weekDayFormatter release];
    }
    else
    {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle]; // Display the date as well
    }
    
    if(dateFormatPrefix != nil) // We have a day string, add hour only
        { 
        label = [NSString stringWithFormat:@"%@ %@", dateFormatPrefix, [dateFormatter stringFromDate:self]];
    }
    else  // Use the full date
    {
        label = [dateFormatter stringFromDate:self];
    }
    
    [dateFormatter release];
    
    return label;
}


+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    calendar = [[NSCalendar currentCalendar] retain];
    displayFormatter = [[NSDateFormatter alloc] init];
    
    [pool drain];
}

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
    // get a midnight version of ourself:
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
    [mdf release];
    
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
    return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
    NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
    NSString *text = nil;
    switch (daysAgo) {
        case 0:
            text = @"Today";
            break;
        case 1:
            text = @"Yesterday";
            break;
        default:
            text = [NSString stringWithFormat:@"%d days ago", daysAgo];
    }
    return text;
}

- (NSUInteger)weekday {
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
    return [weekdayComponents weekday];
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];
    NSDate *date = [inputFormatter dateFromString:string];
    [inputFormatter release];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime
{
    /*
     * if the date is in today, display 12-hour time with meridian,
     * if it is within the last 7 days, display weekday name (Friday)
     * if within the calendar year, display as Jan 23
     * else display as Nov 11, 2008
     */
    
    NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                     fromDate:today];
    
    NSDate *midnight = [calendar dateFromComponents:offsetComponents];
    
    NSString *displayString = nil;
    
    // comparing against midnight
    if ([date compare:midnight] == NSOrderedDescending) {
        if (prefixed) {
            [displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
        } else {
            [displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
        }
    } else {
        // check if date is within last 7 days
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
        [componentsToSubtract release];
        if ([date compare:lastweek] == NSOrderedDescending) {
            if (displayTime)
                [displayFormatter setDateFormat:@"EEEE h:mm a"]; // Tuesday
            else
                [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
        } else {
            // check if same calendar year
            NSInteger thisYear = [offsetComponents year];
            
            NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                           fromDate:date];
            NSInteger thatYear = [dateComponents year];
            if (thatYear >= thisYear) {
                if (displayTime)
                    [displayFormatter setDateFormat:@"MMM d h:mm a"];
                else
                    [displayFormatter setDateFormat:@"MMM d"];
            } else {
                if (displayTime)
                    [displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
                else
                    [displayFormatter setDateFormat:@"MMM d, yyyy"];
            }
        }
        if (prefixed) {
            NSString *dateFormat = [displayFormatter dateFormat];
            NSString *prefix = @"'on' ";
            [displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
        }
    }
    
    // use display formatter to return formatted date string
    displayString = [displayFormatter stringFromDate:date];
    return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
    // preserve prior behavior
    return [self stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
    return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    [outputFormatter release];
    return timestamp_str;
}

- (NSString *)string {
    return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateStyle:dateStyle];
    [outputFormatter setTimeStyle:timeStyle];
    NSString *outputString = [outputFormatter stringFromDate:self];
    [outputFormatter release];
    return outputString;
}

- (NSDate *)beginningOfWeek {
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we'll use the default calendar and hope for the best
    
    NSDate *beginningOfWeek = nil;
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
                           interval:NULL forDate:self];
    if (ok) {
        return beginningOfWeek;
    }
    
    // couldn't calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question. (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    [componentsToSubtract release];
    
    //normalize to midnight, extract the year, month, and day components and create a new date from those components.
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                               fromDate:beginningOfWeek];
    return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    // Get the weekday component of the current date
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                               fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    [componentsToAdd release];
    
    return endOfWeek;
}

+ (NSString *)dateFormatString {
    return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
    return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
    return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {
    return [NSDate timestampFormatString];
}


@end
