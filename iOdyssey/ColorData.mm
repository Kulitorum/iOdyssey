//
//  ColorData.m
//  iOdyssey
//
//  Created by Kulitorum on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorData.h"
#import "iOdysseyAppDelegate.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"

@implementation ColorData

@synthesize isGettingBOOKING_STATE;

- (id)init
{
    self = [super init];
    if (self)
		{
		}
    
    return self;
}
-(ColorInfo*)GetColor:(CStatus) STATUS withPCODE:(PCODE)pcode
{
	if(pcode == P_OPEN)
		{
		return &colors[STATUS];
		}
	if(pcode > colors2.size())
		return &colors[0];	// safe
		
	return &colors2[pcode];
}

- (void)RequestColorData
{
	isGettingBOOKING_STATE = NO;
    cout << "Request Color Data" << endl;

	NSString *request = [NSString stringWithFormat:@"SELECT * FROM dbo.BOOKING_SLOT_STATUS_CODE WHERE SITE_KEY = %d",AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
	//	[AppDelegate.client executeQuery:@"SELECT * FROM dbo.BOOKING_SLOT_STATUS_CODE;" withDelegate:self];
}
- (void)RequestColorData2
{
	isGettingBOOKING_STATE = YES;
    cout << "Request Color Data2" << endl;
/*
	NSString *request = [NSString stringWithFormat:@"SELECT * FROM dbo.BOOKING_STATE WHERE SITE_KEY = %d AND IS_CURRENT=1",AppDelegate->loginData.Login.SITE_KEY];
	[AppDelegate.client executeQuery:request withDelegate:self];
*/
	[AppDelegate.client executeQuery:@"SELECT * FROM dbo.BOOKING_STATE" withDelegate:self];
}

void ColorInfo::buildGradients()
{
    NSArray  *normalGradientLocations;  // Relative locations
    NSArray  *highlightGradientLocations;  // Relative locations

//	if(normalGradient)		CGGradientRelease(normalGradient);
//	if(highlightGradient)	CGGradientRelease(highlightGradient);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

	float r=(float)COLOR_RED/255.0f;
	float g=(float)COLOR_GREEN/255.0f;
	float b=(float)COLOR_BLUE/255.0f;
	
    NSMutableArray *normalGradientColors = [NSMutableArray arrayWithCapacity:5];
    UIColor *color = [UIColor colorWithRed:r+0.2f green:g+0.2f blue:b+0.2f alpha:1.0];
    [normalGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    [normalGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:r+0.3f green:g+0.3f blue:b+0.3f alpha:1.0];
    [normalGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:r+0.1f green:g+0.1f blue:b+0.1f alpha:1.0];
    [normalGradientColors addObject:(id)[color CGColor]];
    normalGradientLocations = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:1.0f],
                                    [NSNumber numberWithFloat:0.55f],
                                    [NSNumber numberWithFloat:0.5f],
                                    [NSNumber numberWithFloat:0.0f],
                                    nil];

	int locCount = [normalGradientLocations count];
	CGFloat locations[locCount];
	for (int i = 0; i < [normalGradientLocations count]; i++)
        {
		NSNumber *location = [normalGradientLocations objectAtIndex:i];
		locations[i] = [location floatValue];
        }
	normalGradient = CGGradientCreateWithColors(space, (CFArrayRef)normalGradientColors, locations) ;
	CGGradientRetain(normalGradient);
	
    NSMutableArray *highlightGradientColors = [NSMutableArray arrayWithCapacity:5];
    color = [UIColor colorWithRed:0.467 green:0.009 blue:0.005 alpha:1.0];
    [highlightGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.754 green:0.562 blue:0.562 alpha:1.0];
    [highlightGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.543 green:0.212 blue:0.212 alpha:1.0];
    [highlightGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.5 green:0.153 blue:0.152 alpha:1.0];
    [highlightGradientColors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.388 green:0.004 blue:0.0 alpha:1.0];
    [highlightGradientColors addObject:(id)[color CGColor]];
    
    highlightGradientLocations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0f],
                                       [NSNumber numberWithFloat:1.0f],
                                       [NSNumber numberWithFloat:0.715f],
                                       [NSNumber numberWithFloat:0.513f],
                                       [NSNumber numberWithFloat:0.445f],
                                       nil];
	
        CGFloat highlightlocations[[highlightGradientLocations count]];
        for (int i = 0; i < [highlightGradientLocations count]; i++)
			{
            NSNumber *location = [highlightGradientLocations objectAtIndex:i];
            highlightlocations[i] = [location floatValue];
			}
        
	highlightGradient = CGGradientCreateWithColors(space, (CFArrayRef)highlightGradientColors, highlightlocations);
	CGGradientRetain(highlightGradient);
	CGColorSpaceRelease(space);
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	cout << "Got ColorData, Processing" << endl;
	//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	if (query.succeeded)
		{
		if(isGettingBOOKING_STATE)
			{
			int a = [[query.resultSets objectAtIndex:0] recordCount];
			if(P_ERROR > a)
				a=P_ERROR;	// END OF ENUM MARKER
			colors2.resize(a+1);

			for (SqlResultSet *resultSet in query.resultSets)
				{
				for (int i = 0; i < resultSet.fieldCount; i++)
					{
					[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
					}
				[outputString appendString:@"\r\n--------\r\n"];
				
				cout << [outputString UTF8String];
				
				//	id Name ABBR Color Remark
				
				NSInteger id = [resultSet indexForField:@"id"];
				NSInteger Name = [resultSet indexForField:@"Name"];
				NSInteger ABBR = [resultSet indexForField:@"ABBR"];
				NSInteger Color = [resultSet indexForField:@"Color"];
				
				ColorInfoBookingState C;
				
				while ([resultSet moveNext])
					{
					C.id = [ resultSet getInteger: id ];
					C.Name = [resultSet getString: Name];
					C.Color = [resultSet getInteger:Color];
					C.COLOR_RED = C.Color & 0xff;
					C.COLOR_GREEN = (C.Color>>8) & 0xff;
					C.COLOR_BLUE = (C.Color>>16) & 0xff;
					
					float factor = 255.0f;
					CGFloat BK_components[] = {C.COLOR_RED/factor, C.COLOR_GREEN/factor, C.COLOR_BLUE/factor, 1.0};
					C.COLOR = CGColorCreate(colorspace, BK_components);   // define color
					C.ABBR = [resultSet getString: ABBR];
					
					if(C.ABBR == nil)
						C.ABBR=@"ROS";
					C.pcode = P_UNKNOWN;
					if([C.ABBR compare:@"O"] == NSOrderedSame) C.pcode = P_OPEN;
					else if([C.ABBR compare:@"F"] == NSOrderedSame) C.pcode = P_FINISHED;
					else if([C.ABBR compare:@"A"] == NSOrderedSame) C.pcode = P_APPROVED;
					else if([C.ABBR compare:@"P"] == NSOrderedSame) C.pcode = P_PRECALC;
					else if([C.ABBR compare:@"Q"] == NSOrderedSame) C.pcode = P_PROFORMA;
					else if([C.ABBR compare:@"I"] == NSOrderedSame) C.pcode = P_INVOICED;
					else if([C.ABBR compare:@"M"] == NSOrderedSame) C.pcode = P_LOGGEDOUT;
					else if([C.ABBR compare:@"G"] == NSOrderedSame) C.pcode = P_GRATIS;
					if(C.pcode == P_UNKNOWN)
						DLog(@"UNKNOWN PCODE: %@", C.ABBR);
					C.buildGradients();
					colors2[C.pcode]=C;
					}
				}
			}
		else
			{
			int a = [[query.resultSets objectAtIndex:0] recordCount];
			if(ERROR > a)
				a=ERROR;	// END OF ENUM MARKER
			colors.resize(a+1);
			
			colors[A16].COLOR_RED = 190;
			colors[A16].COLOR_GREEN = 120;
			colors[A16].COLOR_BLUE = 0;
			colors[A35].COLOR_RED = 120;
			colors[A35].COLOR_GREEN = 0;
			colors[A35].COLOR_BLUE = 180;
			colors[SIP].COLOR_RED = 60;
			colors[SIP].COLOR_GREEN = 220;
			colors[SIP].COLOR_BLUE = 100;
			colors[A16].COLOR2 = 0xff0000;
			colors[A35].COLOR2 = 0x0000ff;
			colors[SIP].COLOR2 = 0x00ff00;
			
			colors[A16].buildGradients();
			colors[A35].buildGradients();
			colors[SIP].buildGradients();
			
			float factor = 255.0f;
				{
				CGFloat BK_components[] = {colors[A16].COLOR_RED/factor, colors[A16].COLOR_GREEN/factor, colors[A16].COLOR_BLUE/factor, 1.0};
				colors[A16].COLOR = CGColorCreate(colorspace, BK_components);   // define color
				}
				{
				CGFloat BK_components[] = {colors[A35].COLOR_RED/factor, colors[A35].COLOR_GREEN/factor, colors[A35].COLOR_BLUE/factor, 1.0};
				colors[A35].COLOR = CGColorCreate(colorspace, BK_components);   // define color
				}
				{
				CGFloat BK_components[] = {colors[SIP].COLOR_RED/factor, colors[SIP].COLOR_GREEN/factor, colors[SIP].COLOR_BLUE/factor, 1.0};
				colors[SIP].COLOR = CGColorCreate(colorspace, BK_components);   // define color
				}
			
			for (SqlResultSet *resultSet in query.resultSets)
				{
				for (int i = 0; i < resultSet.fieldCount; i++)
					{
					[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
					}
				[outputString appendString:@"\r\n--------\r\n"];
				
				
				NSInteger SSC_KEY = [resultSet indexForField:@"SSC_KEY"];
				NSInteger SUB_KEY = [resultSet indexForField:@"SUB_KEY"];
				NSInteger SSC_NAME = [resultSet indexForField:@"SSC_NAME"];
				NSInteger ABBR = [resultSet indexForField:@"ABBR"];
				NSInteger COLOR_RED = [resultSet indexForField:@"COLOR_RED"];
				NSInteger COLOR_GREEN = [resultSet indexForField:@"COLOR_GREEN"];
				NSInteger COLOR_BLUE = [resultSet indexForField:@"COLOR_BLUE"];
				NSInteger COLOR2 = [resultSet indexForField:@"COLOR2"];
				
				ColorInfo C;
				
				while ([resultSet moveNext])
					{
					C.SSC_KEY = [ resultSet getInteger: SSC_KEY ];
					if(C.SSC_KEY == 10)
						continue;
					C.SUB_KEY = [ resultSet getInteger: SUB_KEY ];
					
					C.SSC_NAME = [resultSet getString: SSC_NAME];
					C.COLOR_RED = [resultSet getInteger:COLOR_RED];
					C.COLOR_GREEN = [resultSet getInteger:COLOR_GREEN];
					C.COLOR_BLUE = [resultSet getInteger:COLOR_BLUE];
					
					float factor = 255;
					CGFloat BK_components[] = {C.COLOR_RED/factor, C.COLOR_GREEN/factor, C.COLOR_BLUE/factor, 1.0};         // the color
					C.COLOR = CGColorCreate(colorspace, BK_components);   // define color
					
					C.COLOR2 = [resultSet getInteger:COLOR2];				
					
					C.ABBR = [resultSet getString: ABBR];
					
					if(C.ABBR == nil)
						C.ABBR=@"ROS";
					C.STATUS = UNKNOWN;
					if([C.ABBR compare:@"ROS"] == NSOrderedSame) C.STATUS = ROS;
					else if([C.ABBR compare:@"BKS"] == NSOrderedSame) C.STATUS = BKS;
					else if([C.ABBR compare:@"BK"] == NSOrderedSame) C.STATUS = BK;
					else if([C.ABBR compare:@"16"] == NSOrderedSame) C.STATUS = A16;// -
					else if([C.ABBR compare:@"35"] == NSOrderedSame) C.STATUS = A35;// -
					else if([C.ABBR compare:@"HL1"] == NSOrderedSame) C.STATUS = HL1;
					else if([C.ABBR compare:@"HL2"] == NSOrderedSame) C.STATUS = HL2;
					else if([C.ABBR compare:@"IO"] == NSOrderedSame) C.STATUS = IO;//-
					else if([C.ABBR compare:@"CNI"] == NSOrderedSame) C.STATUS = CNI;
					else if([C.ABBR compare:@"CND"] == NSOrderedSame) C.STATUS = CND;
					else if([C.ABBR compare:@"P01"] == NSOrderedSame) C.STATUS = P01;
					else if([C.ABBR compare:@"N/A"] == NSOrderedSame) C.STATUS = NA;//- (N/A)
					else if([C.ABBR compare:@"MET"] == NSOrderedSame) C.STATUS = MET;
					else if([C.ABBR compare:@"TRA"] == NSOrderedSame) C.STATUS = TRA;
					else if([C.ABBR compare:@"SIP"] == NSOrderedSame) C.STATUS = SIP;//-
					else if([C.ABBR compare:@"GRATIS"] == NSOrderedSame) C.STATUS = GRATIS;
					
					C.buildGradients();
					
					colors[C.STATUS] = C;

//					colors.push_back(C);
					}
				
				}
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
	[AppDelegate RequestNextDataType];
}

-(void)dealloc
{
	for(int i=0;i<colors.size();i++)
		{
		[colors[i].SSC_NAME release];
		[colors[i].ABBR release];
		CGColorRelease(colors[i].COLOR);
		}
	colors.clear();
	
	for(int i=0;i<colors2.size();i++)
		{
		[colors2[i].Name release];
		}
	colors2.clear();
}

@end //ColorData
