//
//  GanttView.m
//  iSqlExample
//
//  Created by Michael Holm on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GanttView.h"
#include <iostream>
#include <sstream>

//#include "NSDate-Utilities.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import "iOdysseyAppDelegate.h"
#import "Timer.h"

#include "ColorData.h"
#import <Foundation/Foundation.h>

#include<iostream>

using namespace std;

@implementation GanttView
@synthesize DoneUpdating;
@synthesize RESOURCENAMEWIDTH;
@synthesize needsInit;
@synthesize contentSizeNeedsUpadte;

@synthesize invisibleScrollView;
@synthesize bogosViewForZooming;

int HOURLINEYSTART=28;

CGColorRef UNKNOWN_COLOR;
CGColorRef GRATIS_COLOR;
CGColorRef BLACK_COLOR;
CGColorRef WHITE_COLOR;
CGColorRef GREY_COLOR;
CGColorRef BLUE_TEXT_COLOR;

UIImage *selectedResourceImage=nil;

void DrawBooking(CGRect rectangle, Booking &book, float y, float h, CGContextRef context, CGColorSpaceRef colorspace, CGRect *drawRectangle);


- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	AppDelegate->viewData.Resources.clear();
	
    cout << "Got Resource data, processing" << endl;
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
            while ([resultSet moveNext])
				{
				// RE_KEY SRT_ORDER HEADER_TXT ITEM_TYPE RE_NAME START_DAY LEAVE_DAY GENERIC SITE_KEY RES_STAFF TYPE IS_CURRENT 
				
				if( [resultSet getInteger:[resultSet indexForField:@"RE_KEY"]] == -1) // Header
					{
					string name("");
					Resource ting(@"",-1);
					NSString *sName = [ resultSet getString: [resultSet indexForField:@"HEADER_TXT"] ];
					if ([sName isKindOfClass:[NSString class]])
						ting.RE_NAME=[sName copy];
					AppDelegate->viewData.AddResource(ting);
					}
				else
					{
					NSString *name;
					if([[resultSet getString:[resultSet indexForField:@"TYPE"]] compare:@"S"] == NSOrderedSame) // Staff
						{
						NSInteger indexOfName = [resultSet indexForField:@"RES_STAFF"];
						if(indexOfName != -1)
							{
							NSString *sName = [ resultSet getString: indexOfName ];
							if ([sName isKindOfClass:[NSString class]])
								name = [sName copy];
							else
								name = [[resultSet getString: [resultSet indexForField:@"RE_NAME"]] copy];
							}
						}
					else
						{
						name = [resultSet getString:[resultSet indexForField:@"RE_NAME"]];
						}
					Resource ting( name, [resultSet getInteger:[resultSet indexForField:@"RE_KEY"]]);
					
					if(ting.RE_KEY == AppDelegate->loginData.Login.RE_KEY)
						{
						bool hasMe=NO;
						for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)
							{
							if(AppDelegate->viewData.Resources[i].RE_KEY == ting.RE_KEY)
								{
								hasMe = YES;
								break;
								}
							}
						if(hasMe == NO) // Add me
							AppDelegate->viewData.AddResource(ting);
						}	// if me
					else
						{
						AppDelegate->viewData.AddResource(ting);
						}
					}
				}
			}
		// make sure the current login resource is there too
		/*		bool hasMe=NO;
		 iOdysseyAppDelegate *asd = AppDelegate;
		 for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)
		 {
		 if(AppDelegate->viewData.Resources[i].RE_KEY == AppDelegate->loginData.Login.RE_KEY)
		 {
		 hasMe = YES;
		 break;
		 }
		 }
		 if(hasMe == NO) // Add me
		 {
		 Resource ting(AppDelegate->loginData.Login.FULL_NAME,AppDelegate->loginData.Login.RE_KEY);
		 AppDelegate->viewData.AddResource(ting);
		 }*/
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];    [alert show];
			[alert release];   
		}
	
	// check resources
	//	for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)
	//	cout << "             " << [AppDelegate->viewData.Resources[i].RE_NAME UTF8String] << endl;
	
	
	if([AppDelegate RequestNextDataType] == NO)
		[AppDelegate->ganttviewcontroller RequestBookingData];
	
	contentSizeNeedsUpadte=YES;
}

/*
 RE_KEY SRT_ORDER HEADER_TXT ITEM_TYPE RE_NAME START_DAY LEAVE_DAY GENERIC SITE_KEY IS_CURRENT 
 --------
 33 | 101 | 1 | <null> | 0 | Flame / Nuke | 1999-03-01 00:00:00 +0000 | 2015-12-31 00:00:00 +0000 | 0 | 9999 | 1 | 
 33 | 102 | 2 | <null> | 0 | Flame  | 1999-03-01 00:00:00 +0000 | 2015-12-31 00:00:00 +0000 | 0 | 9999 | 1 | 
 33 | 104 | 3 | <null> | 0 | Nuke 2 | 2009-09-01 00:00:00 +0000 | 2015-12-31 00:00:00 +0000 | 0 | 9999 | 1 | 
 */

- (id)initWithCoder:(NSCoder*)aDecoder 
{
    if(self = [super initWithCoder:aDecoder]) 
		{
		needsInit=YES;
		}
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    cout << "INIT" << endl;
    if (self) {
		needsInit=YES;
    }
    return self;
}

-(id)init
{
	self= [super init];
    if (self) {
		needsInit=YES;
    }
    return self;
}

- (IBAction)Redraw {
    [self setNeedsDisplay];
}

void DrawText(CGRect rect, CGContextRef context, float posX, float posY, NSString *str, string fontName, float fontSize, CGRect clipping, bool centered, CGColorRef color)
{
	CGContextSaveGState(context);
	CGContextClipToRect (context, clipping);
	
	CGContextSetFillColorWithColor(context, color);
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    
	// Some initial setup for our text drawing needs.
	// First, we will be doing our drawing in Helvetica-36pt with the MacRoman encoding.
	// This is an 8-bit encoding that can reference standard ASCII characters
	// and many common characters used in the Americas and Western Europe.
	CGContextSelectFont(context, fontName.c_str(), fontSize, kCGEncodingMacRoman);
	// Next we set the text matrix to flip our text upside down. We do this because the context itself
	// is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	
	if(centered)
		{
		CGPoint pt;
		CGContextSetTextDrawingMode(context, kCGTextInvisible);
		UIFont * font = [UIFont fontWithName:@"Helvetica" size:11];
		[str drawAtPoint:CGPointMake(0, 0) withFont:font];
		pt = CGContextGetTextPosition(context);
		posX=(posX - pt.x/2);
		}
	
	// And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	//	[str drawAtPoint:CGPointMake(posX, posY+11) withFont:[UIFont fontWithName:@"Helvetica" size:11]];
	[str drawAtPoint:CGPointMake(posX, posY+11) forWidth:rect.size.width-posX-5 withFont:[UIFont fontWithName:@"Helvetica" size:11] lineBreakMode:UILineBreakModeTailTruncation];
	CGContextRestoreGState(context);
}

CGColorRef BKS_HighLightCOLOR;
CGColorRef BKS_LowLightCOLOR;

void drawGradientInRect(CGRect rect, CGColorSpaceRef colorSpace, CGContextRef context, float r, float g, float b, float a)
{
    CGFloat startComponents[4] = {r, g, b,a };
    CGFloat endComponents[4] = { r*0.7, g*0.7, b*0.7, a };
	CGColorRef startColor = (CGColorRef)[(id)CGColorCreate(colorSpace, startComponents) autorelease];	
	CGColorRef endColor = (CGColorRef)[(id)CGColorCreate(colorSpace, endComponents) autorelease];	
	
    NSArray *array = [NSArray arrayWithObjects: (id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors (colorSpace, (CFArrayRef)array, NULL);
    CGPoint endPoint = rect.origin;
    endPoint.y += rect.size.height;
    
	// Don't let the gradient bleed all over everything
    CGContextSaveGState (context);
	{
	CGContextClipToRect (context, rect);
	CGContextDrawLinearGradient (context, gradient, rect.origin, endPoint, 0);
	}
    CGContextRestoreGState (context);
    
	// frame it / outline
    CGFloat frameComponents[4] = {0,0,0,a};
	CGColorRef frameColor = (CGColorRef)[(id)CGColorCreate(colorSpace, frameComponents) autorelease];	
    CGContextSetStrokeColorWithColor(context, frameColor);
    CGContextStrokeRect (context, rect);
	
    CGGradientRelease (gradient);
	//    CGColorRelease (startColor);
	//    CGColorRelease (endColor);
} // drawGradientInRect

-(void) DrawDateGrid:(CGRect) rect withy:(float)y withColorSpace:(CGColorSpaceRef)colorSpace WithContext:(CGContextRef) context
{
    float DateWindow = AppDelegate.displayEnd.nstimeInterval() - AppDelegate.displayStart.nstimeInterval();
	
	if(DateWindow < 0) 	return;// Bug fix - sometimes displayend is less then displaystart, and we end in a dead-end loop.
	
	float hours = DateWindow/3600;  // number of hours we want to draw
    float width = rect.size.width;
    float graphWidth = width-RESOURCENAMEWIDTH;
    float graphHeight = rect.size.height;
	
    float pixelsPrHour = graphWidth/hours;
    float pixelsPrMinute = pixelsPrHour/60;
    
    CGFloat theColor[4] = { 0.0, 0.0, 0.0, 0.1 };
    CGFloat theDayColor[4] = { 82.0/255, 82.0/255, 82.0/255, 1.0 };
	//	CGFloat theTopLineColor[4] = { 0.7, 0.8, 1, 1 };
	
	CGColorRef gridColor = (CGColorRef)[(id)CGColorCreate(colorSpace, theColor) autorelease];	
	CGColorRef DayColor = (CGColorRef)[(id)CGColorCreate(colorSpace, theDayColor) autorelease];	
	//	CGColorRef TopLineColor = (CGColorRef)[(id)CGColorCreate(colorSpace, theTopLineColor) autorelease];	
	// Draw yellow square
	/*
	 CGContextSetFillColorWithColor(context, TopLineColor);
	 CGRect rectangle = CGRectMake(0,0,width,HOURLINEYSTART);
	 CGContextAddRect(context, rectangle);	
	 CGContextFillPath(context);
	 */	
	
	// Datebar (top bar) background
	CGFloat bgColorTop[4] = { 11.0/255, 42.0/255, 85.0/255, 1.0 };
	CGFloat bgColorBottom[4] = { 11.0/255, 42.0/255, 85.0/255, 1.0 };
	CGColorRef BGColorTop = (CGColorRef)[(id)CGColorCreate(colorSpace, bgColorTop) autorelease];	
	CGColorRef BGColorBottom = (CGColorRef)[(id)CGColorCreate(colorSpace, bgColorBottom) autorelease];	
	CGContextSaveGState(context);
	CGRect rectangle = CGRectMake(RESOURCENAMEWIDTH,0,width,HOURLINEYSTART);
	drawGradientWithGloss(context, rectangle, BGColorTop,  BGColorBottom);

	
	// Mark weekends
	{
	Date date=AppDelegate.displayStart;
	while(date.nstimeInterval() < AppDelegate.displayEnd.DaysAfter(1).nstimeInterval())
		{
		[[UIColor colorWithRed:0 green:1 blue:0 alpha:0.02] setFill];
		if(date.isWeekend())
			{
			float secondsAgo=date.StartOfDay().nstimeInterval()-AppDelegate.displayStart.nstimeInterval();
			float start = secondsAgo/60*pixelsPrMinute;
			float x1 = (start<0?0:start);
			float xsize=(pixelsPrHour*24)-(start<0?fabs(start):0);
			CGRect rectangle = CGRectMake(RESOURCENAMEWIDTH+x1,HOURLINEYSTART,xsize,700);
			CGContextFillRect(context, rectangle);	
			// Datebar (top bar) background
			CGFloat bgColorTop[4] = { 11.0/255, 85.0/255, 42.0/255, 1.0 };
			CGFloat bgColorBottom[4] = { 11.0/255, 85.0/255, 42.0/255, 1.0 };
			CGColorRef BGColorTop = (CGColorRef)[(id)CGColorCreate(colorSpace, bgColorTop) autorelease];	
			CGColorRef BGColorBottom = (CGColorRef)[(id)CGColorCreate(colorSpace, bgColorBottom) autorelease];	
			CGContextSaveGState(context);
			CGRect rectangle2 = CGRectMake(RESOURCENAMEWIDTH+x1,0,xsize,HOURLINEYSTART);
			drawGradientWithGloss(context, rectangle2, BGColorTop,  BGColorBottom);
			}
		date = date.DaysAfter(1);
		}
	}

	
	// behind year
	CGFloat bgColorYear[4] = { 129.0/255, 146.0/255, 160.0/255, 1.0 };
	CGColorRef BGColorYear = (CGColorRef)[(id)CGColorCreate(colorSpace, bgColorYear) autorelease];	
	CGRect rectangle2 = CGRectMake(0,0,RESOURCENAMEWIDTH,HOURLINEYSTART);
	drawGradientWithGloss(context, rectangle2, BGColorYear,  BGColorYear);
	CGContextRestoreGState(context);
	
	int hourStep=1;
	while( (pixelsPrHour*hourStep) < 20 && hourStep < 8 )
		hourStep*=2;
	
    float minuteOffset=((int)AppDelegate.displayStart.nstimeInterval()%3600)/60;   // number of minutes before the first full hour
	
    int hourValue = AppDelegate.displayStart.HourValue();
    float x = -minuteOffset*pixelsPrMinute;
	
	int hourOffset=hourValue%hourStep;
	x-=hourOffset*pixelsPrHour;
	
	hourValue=hourValue-hourOffset;
	
	
	CGRect clippingRect = CGRectMake(RESOURCENAMEWIDTH,0,graphWidth,graphHeight);
	CGContextSaveGState(context);
	CGContextClipToRect (context, clippingRect);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1); // Hour numbers color
	while(x<graphWidth)
        {
		if(x>0)
			{
			if(hourValue%24<hourStep) // this is line at hour 0
				CGContextSetStrokeColorWithColor(context, DayColor); // fat line
			else
				CGContextSetStrokeColorWithColor(context, gridColor);// thin line
			
			CGContextMoveToPoint(context, x+RESOURCENAMEWIDTH, hourValue%24<hourStep ? 0 : HOURLINEYSTART);
			CGContextAddLineToPoint(context, x+RESOURCENAMEWIDTH, rect.size.height);
			CGContextStrokePath(context);
			if((hourValue%24) != 0)
				{
				NSString *aString = [NSString stringWithFormat:@"%d", (hourValue%24)];
				[aString drawAtPoint:CGPointMake(x-5+RESOURCENAMEWIDTH, HOURLINEYSTART*0.7) withFont:[UIFont fontWithName:@"STHeitiSC-Light" size:8]];
				}
			}
        hourValue+=hourStep;
        x+=pixelsPrHour*hourStep;
		}
	
	// print "Ma-01-Maj" on top line
	Date DateOnly(AppDelegate.displayStart);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	double minutesTillMidtday = (AppDelegate.displayStart.Midtday()-AppDelegate.displayStart).nstimeInterval()/60;
	double xp = minutesTillMidtday*pixelsPrMinute;
	int i=0;
	float xpos =  i*24*pixelsPrHour+RESOURCENAMEWIDTH+xp;
	float lastXpos = -RESOURCENAMEWIDTH;
	while(xpos < width+RESOURCENAMEWIDTH)
		{
		xpos =  i*24*pixelsPrHour+RESOURCENAMEWIDTH+xp;
		if(xpos-lastXpos > 60)
			{
			CGContextSelectFont(context, "Helvetica Bold", 10, kCGEncodingMacRoman);
			CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
			CGContextSetTextDrawingMode(context, kCGTextFill);
			NSString *str = AppDelegate.displayStart.Midtday().DaysAfter(i).FormatForGanttView();
			
			// center
			CGPoint pt;
			CGContextSetTextDrawingMode(context, kCGTextInvisible);
			UIFont * font = [UIFont fontWithName:@"Helvetica" size:11];
			[str drawAtPoint:CGPointMake(0, 0) withFont:font];
			pt = CGContextGetTextPosition(context);
			float posX=(xpos - pt.x/2);
			CGContextSetTextDrawingMode(context, kCGTextFill);
			[str drawAtPoint:CGPointMake(posX, HOURLINEYSTART*0.2) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11]];
			lastXpos = xpos;
			}
		i++;
		}
	// Year....
	CGContextRestoreGState(context);
	
	CGContextSetStrokeColorWithColor(context, DayColor); // fat line
    CGContextMoveToPoint(context, 0, HOURLINEYSTART);
    CGContextAddLineToPoint(context, AppDelegate.ganttDisplayWidth, HOURLINEYSTART);
    CGContextStrokePath(context);
	
	NSString *aString = [NSString stringWithFormat:@"%@ %d", AppDelegate.displayStart.MonthValue(), AppDelegate.displayStart.YearValue()];
	
	CGContextSaveGState(context);
	CGContextSetShadow(context, CGSizeMake(0, 2), 2);
	DrawText(rect, context, RESOURCENAMEWIDTH/2, (HOURLINEYSTART*0.5)-18, aString, "Helvetica", 14, rect, true, WHITE_COLOR);
	CGContextRestoreGState(context);
	
	// Now Line
	NSDate *a=[NSDate date];
	Date now(a);
	
	Date offsetInTime = now.nstimeInterval()-AppDelegate.displayStart.nstimeInterval();
	
	float xposOfNow = (offsetInTime.nstimeInterval()/60)*pixelsPrMinute;
	if(xposOfNow > 0)
		{
		[[UIColor colorWithRed:1 green:0.5 blue:0 alpha:1.0] setStroke];
		CGContextSetLineWidth(context,2);
		CGFloat dashArray[] = {10,10};
		CGContextSetLineDash(context, 0, dashArray, 2);
		CGContextMoveToPoint(context, xposOfNow+RESOURCENAMEWIDTH, HOURLINEYSTART);
		CGContextAddLineToPoint(context, xposOfNow+RESOURCENAMEWIDTH, graphHeight);
		CGContextStrokePath(context);
		CGContextSetLineDash(context, 0, NULL, 0);	// remove dash
		CGContextSetLineWidth(context,1);
		}
}

void DrawBookingResource(CGRect rect, Resource &res, float y, float h, CGContextRef context, CGColorSpaceRef colorspace, float yStart)
{
	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt->RESOURCENAMEWIDTH;
	
	CGRect rectangle = CGRectMake(0,yStart,RESOURCENAMEWIDTH,y-yStart);
	if(res.RE_KEY == -1)									// a header
		drawGradientInRect(rectangle, colorspace, context, 0.6, 0.8, 1.0, 1.0);
	
	bool BlueText=YES;
	
	if(res.RE_KEY == AppDelegate->loginData.Login.RE_KEY)	// the patron that's logged in
		{
		CGRect rectangle = CGRectMake(RESOURCENAMEWIDTH,yStart,AppDelegate->ganttDisplayWidth,y-yStart);
		CGFloat ovrColor[4] = { 0,0,0.5, 0.1 };
		CGColorRef overlayColor = (CGColorRef)[(id)CGColorCreate(colorspace, ovrColor) autorelease];	
		CGContextSetFillColorWithColor(context,  overlayColor);
		CGContextFillRect (context, rectangle);
		/*
		 // draw gloss
		 drawGradientInRect(rectangle, colorspace, context, 0.6, 0.8, 1.0, 0.1);
		 CGColorRef glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
		 CGColorRef glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.46].CGColor;
		 CGColorRef glossColor3 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor;
		 CGRect topHalf = CGRectMake(rectangle.origin.x, rectangle.origin.y, rectangle.size.width, rectangle.size.height/2);
		 drawLinearGradient(context, topHalf, glossColor1, glossColor2);
		 CGRect bottomHalf = CGRectMake(rectangle.origin.x, rectangle.origin.y+rectangle.size.height/2, rectangle.size.width, rectangle.size.height/2);
		 drawLinearGradient(context, bottomHalf, glossColor1, glossColor3);
		 CGContextRestoreGState(context);
		 */
		BlueText=NO;
		}
	res.pickRectangle = rectangle;
	rect.size.width = RESOURCENAMEWIDTH;
	DrawText(rect, context, 5, ((y+yStart)/2)-18, res.RE_NAME , "Helvetica", 9, rectangle, false, BlueText == YES ? BLUE_TEXT_COLOR : BLACK_COLOR);
	
	// Selected
	res.selectRectangle = CGRectMake(RESOURCENAMEWIDTH-50,yStart,50,y-yStart);
	
	//	CGRect drawRect = CGRectMake(RESOURCENAMEWIDTH-35,yStart,35,y-yStart);
	CGPoint drawPoint = CGPointMake(RESOURCENAMEWIDTH-30,((y+yStart)/2)-12);
	if(res.Selected)
		{
		//		CGContextStrokeRect (context, drawRect);
		//		[selectedResourceImage setOverlayColor:[UIColor blueColor]];
		[selectedResourceImage drawAtPoint:drawPoint]; // the selected icon
		}
	
	/*	
	 CGFloat selectedColorArray[4] = { res.Selected,1-res.Selected,0, 0.1 };
	 CGColorRef selectedColor = (CGColorRef)[(id)CGColorCreate(colorspace, selectedColorArray) autorelease];	
	 CGContextSetFillColorWithColor(context,  selectedColor);
	 CGContextFillRect (context, res.selectRectangle);
	 */
	
	
	if(AppDelegate->ganttviewcontroller.isCreatingNewBooking)
		{
		for(int b=0;b<[AppDelegate->theNewBookingControlller->BookedResources count];b++)
			{
            ResourceAndTime* resource = ((ResourceAndTime*)[AppDelegate->theNewBookingControlller->BookedResources objectAtIndex:b]);
			if(resource.RE_KEY == res.RE_KEY)	// Yay! - I'm getting a new booking
				{
				Booking asd;
				asd.RE_KEY = res.RE_KEY;
				asd.STATUS = UNKNOWN;
				asd.pcode = P_OPEN;
				asd.MTYPE = 1;
				asd.FROM_TIME = resource.FROM_TIME;
				asd.TO_TIME = resource.TO_TIME;
				asd.CL_NAME = @"NEW BOOKING";
				asd.Folder_name = @"";
				asd.Resource = @"";
				asd.NAME = @"";
				asd.ACTIVITY = @"";
				
				CGRect slotRect = rect;
				slotRect.size.width = AppDelegate->ganttDisplayWidth;
				
				AppDelegate->ganttviewcontroller.isCreatingNewBooking=NO;	// Trick colors
				DrawBooking(slotRect, asd, yStart, y-yStart-5, context, colorspace, &asd.pickRectangle);
				AppDelegate->ganttviewcontroller.isCreatingNewBooking=YES;	// Trick colors
				
				NSString *StartTime = asd.FROM_TIME.FormatForNewBooking();
				CGPoint pt;
				CGContextSetTextDrawingMode(context, kCGTextInvisible);
				UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
				[StartTime drawAtPoint:CGPointMake(0, 0) withFont:font];
				pt = CGContextGetTextPosition(context);
				CGContextSetTextDrawingMode(context, kCGTextFill);
				
				// Draw start time BG
					{
					float radius=3;
					CGRect rect=asd.pickRectangle;
					//					rect.origin.y -= 15;
					rect.origin.x -= pt.x+15;
					rect.size.width = pt.x+10;
					rect.size.height = 18;
					CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
					CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
					CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1); //STS fixed
					CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
					CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
					CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
					CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
					CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
					CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
					CGRect rect2 = rect;
					rect2.origin.x = asd.pickRectangle.origin.x + asd.pickRectangle.size.width+5;
					CGContextMoveToPoint(context, rect2.origin.x, rect2.origin.y + radius);
					CGContextAddLineToPoint(context, rect2.origin.x, rect2.origin.y + rect2.size.height - radius);
					CGContextAddArc(context, rect2.origin.x + radius, rect2.origin.y + rect2.size.height - radius, radius, M_PI, M_PI / 2, 1); //STS fixed
					CGContextAddLineToPoint(context, rect2.origin.x + rect2.size.width - radius, rect2.origin.y + rect2.size.height);
					CGContextAddArc(context, rect2.origin.x + rect2.size.width - radius, rect2.origin.y + rect2.size.height - radius, radius, M_PI / 2, 0.0f, 1);
					CGContextAddLineToPoint(context, rect2.origin.x + rect2.size.width, rect2.origin.y + radius);
					CGContextAddArc(context, rect2.origin.x + rect2.size.width - radius, rect2.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
					CGContextAddLineToPoint(context, rect2.origin.x + radius, rect2.origin.y);
					CGContextAddArc(context, rect2.origin.x + radius, rect2.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
					
					CGContextSaveGState(context);
					CGContextSetShadow(context, CGSizeMake(0, 2), 5);
					[[UIColor colorWithRed:0.3 green:0.3 blue:0.6 alpha:1.0] setFill];
					CGContextEOFillPath(context);
					// draw gloss, start time
					CGColorRef glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
					CGColorRef glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.46].CGColor;
					CGColorRef glossColor3 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor;
					CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
					drawLinearGradient(context, topHalf, glossColor1, glossColor2);
					CGRect bottomHalf = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height/2, rect.size.width, rect.size.height/2);
					drawLinearGradient(context, bottomHalf, glossColor1, glossColor3);
					// draw gloss, end time
					CGRect topHalf2 = CGRectMake(rect2.origin.x, rect2.origin.y, rect2.size.width, rect2.size.height/2);
					drawLinearGradient(context, topHalf2, glossColor1, glossColor2);
					CGRect bottomHalf2 = CGRectMake(rect2.origin.x, rect2.origin.y+rect2.size.height/2, rect2.size.width, rect2.size.height/2);
					drawLinearGradient(context, bottomHalf2, glossColor1, glossColor3);
					CGContextRestoreGState(context);
					}
				
				[[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0] setFill];
				CGPoint pos=CGPointMake(asd.pickRectangle.origin.x-pt.x-10, asd.pickRectangle.origin.y );
				[StartTime drawAtPoint:pos withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
				pos.x = asd.pickRectangle.origin.x+asd.pickRectangle.size.width+10;
				NSString *EndTime = asd.TO_TIME.FormatForNewBooking();
				[EndTime drawAtPoint:pos withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
				}
			}
		}
	
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
	
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
	
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}
void drawGradientWithGloss(CGContextRef context, CGRect rect, CGColorRef startColor,  CGColorRef endColor)
{
    drawLinearGradient(context, rect, startColor, endColor);
	
    CGColorRef glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35].CGColor;
    CGColorRef glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
	
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
    drawLinearGradient(context, topHalf, glossColor1, glossColor2);
}




void DrawBooking(CGRect rectangle, Booking &book, float y, float h, CGContextRef context, CGColorSpaceRef colorspace, CGRect *drawRectangle)
{
	float RESOURCENAMEWIDTH = AppDelegate->ganttviewcontroller.gantt->RESOURCENAMEWIDTH;
	
    float width = rectangle.size.width;
    float graphWidth = width-RESOURCENAMEWIDTH;
    Date startTime = book.FROM_TIME;
    Date endTime = book.TO_TIME; // make sure length is not zero
	
	Date dStart = AppDelegate.displayStart;
	Date dEnd = AppDelegate.displayEnd;
	
	// Manupulate dStart and dEnd if AppDelegate.ganttDisplayStyle == 0 (8 hours)
	
    Date displayWidth = dEnd-dStart;
    Date BookingStart = book.FROM_TIME - dStart;
    Date BookingEnd = book.TO_TIME - dStart;
	
	/*
	 if(AppDelegate.ganttDisplayStyle == 0)
	 {
	 // if the display spans more then 1 day, check if the booking is valid inside what days.
	 if(BookingStart.HourValue() < 7)
	 {
	 
	 }
	 if(BookingEnd.HourValue() > 18)stu
	 {
	 
	 }
	 }
	 */
	
	double DayNrStart = (double)BookingStart.nstimeInterval() / 86400.0;	// 2.42 = 0.42 into day 2
	double DayNrEnd = (double)BookingEnd.nstimeInterval() / 86400.0;	// 2.42 = 0.42 into day 2
	
	double displayHourStart = 8.0/24.0;
	double displayHourEnd = 18.0/24.0;
	
	double displayHourMult = 1.0f/(displayHourEnd-displayHourStart);
	
	if(AppDelegate.ganttDisplayStyle == 0) //8h
		{
		int dayS = floor(DayNrStart);
		double HourS = ((DayNrStart-dayS)-displayHourStart)*displayHourMult;
		
		int dayE = floor(DayNrEnd);
		double HourE = ((DayNrEnd-dayE)-displayHourStart)*displayHourMult;
		
		if(HourS > 1) return;	// start after display end, skip
		if(HourE < 0) return;	// end is before display start, skip
		
		if(HourS < 0) HourS=0;
		if(HourE < 0) HourE=0;
		if(HourS > 1) HourS=1;
		if(HourE > 1) HourE=1;
		
		
		
		DayNrStart = dayS+HourS;
		DayNrEnd = dayE+HourE;
		}
	
	/*	
	 double tStart = (double)BookingStart.nstimeInterval()/(double)displayWidth.nstimeInterval();   // 10
	 double tEnd = (double)BookingEnd.nstimeInterval()/(double)displayWidth.nstimeInterval();   // 10
	 */
	
	double tStart = DayNrStart/((double)displayWidth.nstimeInterval()/86400);
	double tEnd = DayNrEnd/((double)displayWidth.nstimeInterval()/86400);
	
	if(tStart > 1 || tEnd<0)	return;// booking outside display scope
	
	if(tStart < 0)				// If before display start, hack it.
		tStart = 0;
    if(tEnd > 1)				// if end after display end, hack it
        tEnd = 1;
    
    float xs = RESOURCENAMEWIDTH+tStart*graphWidth;
    float xe = RESOURCENAMEWIDTH+tEnd*graphWidth;
    float w = xe-xs;
	
    CGRect rect = CGRectMake(xs,y,w,h);
	if(drawRectangle)
		*drawRectangle=rect;// output BBox for touch recognition
	
	ColorInfo *myColor = [AppDelegate.colorData GetColor:book.STATUS withPCODE:book.pcode];
	
	if(AppDelegate->ganttviewcontroller.isCreatingNewBooking)
		[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] setFill];
	else
		CGContextSetFillColorWithColor(context,  myColor->COLOR);
	
	float radius=3.0f;
	// Build shape
	
//		[[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0] setFill];

		CGContextBeginPath(context);
		CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);	
		CGContextClosePath(context);
		CGContextSaveGState(context);
		CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
		CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
		CGContextClip(context);
		if(myColor->normalGradient!=0)
			CGContextDrawLinearGradient(context, myColor->normalGradient, startPoint, endPoint, 0);
		CGContextRestoreGState(context);
		
		if(book.BOKEYSELECTED)
			{
			CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
			CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
			CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1); //STS fixed
			CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
			CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
			CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
			CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
			CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
			CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
			CGContextSaveGState(context);
			[[UIColor colorWithRed:1 green:0 blue:0 alpha:1.0] setStroke];
			CGContextSetLineWidth(context, 4.0);
			CGContextStrokePath(context);
			CGContextRestoreGState(context);
			}
	
	//	CGContextFillRect (context, rect);
	// frame it / outline
	//    CGContextSetStrokeColorWithColor(context, BLACK_COLOR);
	//    CGContextStrokeRect (context, rectangle);
	
	/*
	 if ([book.TYPE compare:@"S"] == NSOrderedSame)
	 drawGradientInRect(rectangle, colorspace, context, 0.3, 0.8, 0.7, 1);
	 else
	 drawGradientInRect(rectangle, colorspace, context, 0.6, 0.8, 0.7, 1);
	 */
	// Type client on top
	
	CGContextSaveGState(context);
	CGContextClipToRect (context, rect);
	CGFloat theTextColor[4] = { 1.0, 1.0, 1.0, 1.0 };
	CGColorRef TextColor = (CGColorRef)[(id)CGColorCreate(colorspace, theTextColor) autorelease];	
	CGContextSetFillColorWithColor(context, TextColor);
	CGContextSelectFont(context, "HelveticaNeue-Bold", 8, kCGEncodingMacRoman);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSetTextDrawingMode(context, kCGTextFill);
	UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
	
	y+=3;
	
    CGColorRef textShadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
	CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0, textShadowColor);
	
	if(AppDelegate.ganttDisplaySmallLarge && AppDelegate->ganttviewcontroller.isCreatingNewBooking == NO)
		{
		NSString* status;
		switch(book.STATUS)
			{
				case ROS: status=@"ROS"; break;
				case BKS: status=@"BKS"; break;
				case BK: status=@"BK"; break;
				case A16: status=@"A16"; break;
				case A35: status=@"A35"; break;
				case HL1: status=@"HL1"; break;
				case HL2: status=@"HL2"; break;
				case IO: status=@"IO"; break;
				case CNI: status=@"CNI"; break;
				case CND: status=@"CND"; break;
				case P01: status=@"P01"; break;
				case NA: status=@"NA"; break;
				case MET: status=@"MET"; break;
				case TRA: status=@"TRA"; break;
				case SIP: status=@"SIP"; break;
				case GRATIS: status=@"GRATIS"; break;
				case INVOICED: status=@"INVOICED"; break;
				case UNKNOWN: status=@"UNKNOWN"; break;
				case ERROR: status=@"ERROR"; break;
			}
		NSString* pcode;
		switch(book.pcode)
			{
				case P_UNKNOWN: pcode=@"UNKNOWN"; break;
				case P_OPEN: pcode=@"OPEN"; break;
				case P_FINISHED: pcode=@"FINISHED"; break;
				case P_APPROVED: pcode=@"APPROVED"; break;
				case P_PRECALC: pcode=@"PRECALC"; break;
				case P_PROFORMA: pcode=@"PROFORMA"; break;
				case P_INVOICED: pcode=@"INVOICED"; break;
				case P_LOGGEDOUT: pcode=@"LOGGEDOUT"; break;
				case P_GRATIS: pcode=@"GRATIS"; break;
				default:
				case P_ERROR: pcode=@"ERROR"; break;
			}
		NSString *cellText= [NSString stringWithFormat:	 @"%@/%@",pcode, status];
		
		CGPoint P=rect.origin;
		[book.CL_NAME drawAtPoint:P withFont:font];		P.y+=12;
		[book.Folder_name drawAtPoint:P withFont:font];	P.y+=12;
		[cellText drawAtPoint:P withFont:font];			P.y+=12;
		[book.ACTIVITY drawAtPoint:P withFont:font];	P.y+=12;
		[book.NAME drawAtPoint:P withFont:font];		P.y+=12;
		
		//		[cellText drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		}
	else
		{
		if(AppDelegate.GanttSlotNamesStyle == BOOKINGNAMESTYLE)
			[book.NAME drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		else if(AppDelegate.GanttSlotNamesStyle == PROJECTSTYLE)
			[book.Folder_name drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		else if(AppDelegate.GanttSlotNamesStyle == ACTIVITYSTYLE)
			[book.ACTIVITY drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		else if(AppDelegate.GanttSlotNamesStyle == CLIENTSTYLE)
			[book.CL_NAME drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		else if(AppDelegate.GanttSlotNamesStyle == BOOKINGIDSTYLE)
			[[NSString stringWithFormat:@"%d",book.BO_KEY] drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		else
			[@"ERROR" drawAtPoint:CGPointMake(xs+3, y) withFont:font];
		}
	CGContextRestoreGState(context);
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	
	if(needsInit)
		{
		if(AppDelegate.IsIpad)
			{
			HOURLINEYSTART = 50;
			RESOURCENAMEWIDTH=150;
			}
		else
			RESOURCENAMEWIDTH=100;
		CGFloat BLACK_components[] = {0, 0, 0, 1.0};         // the color
		BLACK_COLOR = CGColorCreate(colorspace, BLACK_components);   // define color
		CGFloat WHITE_components[] = {1, 1, 1, 1.0};         // the color
		WHITE_COLOR = CGColorCreate(colorspace, WHITE_components);   // define color
		CGFloat BLUE_TEXT_COLOR_components[] = {0, 51.0/255, 112.0/255, 1.0};         // the color
		BLUE_TEXT_COLOR = CGColorCreate(colorspace, BLUE_TEXT_COLOR_components);   // define color
		CGFloat GREY_COLOR_components[] = {0, 0, 0, 0.4};         // the color
		GREY_COLOR = CGColorCreate(colorspace, GREY_COLOR_components);   // define color
		needsInit=NO;

//		float w = AppDelegate->ganttDisplayWidth;
		float h = AppDelegate->ganttDisplayHeight;
		
//		CGRect scrollViewFrame = CGRectMake(RESOURCENAMEWIDTH,HOURLINEYSTART,w-RESOURCENAMEWIDTH, h-HOURLINEYSTART-40);
		CGRect scrollViewFrame = CGRectMake(RESOURCENAMEWIDTH,HOURLINEYSTART,1024-RESOURCENAMEWIDTH, h-HOURLINEYSTART-40);
		invisibleScrollView = [[GanttScrollView alloc] initWithFrame:scrollViewFrame];
		[invisibleScrollView setDelegate:AppDelegate->ganttviewcontroller];
		invisibleScrollView.userInteractionEnabled = YES;
		invisibleScrollView.showsVerticalScrollIndicator = YES;
		invisibleScrollView.showsHorizontalScrollIndicator = NO;
		[invisibleScrollView setMinimumZoomScale:0.25];	// 4 days
		[invisibleScrollView setMaximumZoomScale:10.0];
		
		invisibleScrollView.contentSize = CGSizeMake((1024-RESOURCENAMEWIDTH)*3,7700);
		invisibleScrollView.scrollsToTop = NO;
		invisibleScrollView.contentOffset = CGPointMake(1024-RESOURCENAMEWIDTH, 0);

		if(AppDelegate.IOS5 == YES)	// 
			invisibleScrollView.pagingEnabled = NO;
		else
			invisibleScrollView.pagingEnabled = YES;
		invisibleScrollView.bounces = YES;
		
		/*
		bogosViewForZooming = [[UIView alloc] initWithFrame:CGRectMake(0,0,1000,1000)];
		UIImage *img = [UIImage imageNamed:@"1236x500.png"];
		UIImageView *asd = [[UIImageView alloc] initWithImage:img];
		[bogosViewForZooming addSubview:asd];
		[asd release];
		[invisibleScrollView addSubview:bogosViewForZooming];
		*/
		
		[self addSubview:invisibleScrollView];
		contentSizeNeedsUpadte = YES;
		}
	
	if(selectedResourceImage == nil)
		selectedResourceImage = [[UIImage imageNamed:@"selectednoframe.png"] retain];
	
	AppDelegate.ganttDisplayWidth = rect.size.width;
	AppDelegate.ganttDisplayHeight = rect.size.height;
	
	// Behind dates and hours
	/*
	 CGFloat bgColor[4] = { .9,.9,.9, 1.0 };
	 CGColorRef BGColor = CGColorCreate (colorspace, bgColor);
	 CGContextSetFillColorWithColor(context,  BGColor);
	 CGRect clippingRectTop = CGRectMake(0,0,rect.size.width,29);
	 CGContextFillRect (context, clippingRectTop);
	 
	 
	 CGFloat bgColorTop[4] = { 11/255, 42/255, 85/255, 1.0 };
	 CGColorRef BGColorTop = CGColorCreate (colorspace, bgColorTop);
	 CGFloat bgColorBottom[4] = { 11/255, 42/255, 85/255, 1.0 };
	 CGColorRef BGColorBottom = CGColorCreate (colorspace, bgColorBottom);
	 CGContextSaveGState(context);
	 CGRect clippingRectTop = CGRectMake(0,0,rect.size.width,29);
	 drawGradientWithGloss(context, clippingRectTop, BGColorTop,  BGColorBottom);
	 CGContextRestoreGState(context);
	 */
	CGContextSetTextDrawingMode(context, kCGTextFill);
	// Behind resource names
	CGFloat bgColor[4] = { 197.0/255, 204.0/255, 202.0/255, 1.0 };
	CGColorRef BGColor = (CGColorRef)[(id)CGColorCreate(colorspace, bgColor) autorelease];	
	CGContextSetFillColorWithColor(context,  BGColor);
	CGRect clippingRectleft = CGRectMake(00,HOURLINEYSTART,RESOURCENAMEWIDTH,rect.size.height-HOURLINEYSTART);
    CGContextFillRect (context, clippingRectleft);
	// Pattern Behind resource names
	CGFloat paColor[4] = { 203.0/255, 210.0/255, 216.0/255, 1.0 };
	CGColorRef patternColor = (CGColorRef)[(id)CGColorCreate(colorspace, paColor) autorelease];	
	CGContextSetStrokeColorWithColor(context,  patternColor);
	for(int x=3;x<RESOURCENAMEWIDTH;x+=7)
		{
		CGContextMoveToPoint(context, x, HOURLINEYSTART);
		CGContextAddLineToPoint(context, x, rect.size.height);
		}
	CGContextStrokePath(context);
	
	
    Date start = AppDelegate.displayStart;
    Date end =   AppDelegate.displayEnd;
	
	
	[self DrawDateGrid:rect withy:HOURLINEYSTART withColorSpace:colorspace WithContext:context];
	
    float y=HOURLINEYSTART-AppDelegate.displayStartY+5;
    float h=AppDelegate.ganttBookingHeight;
	
	if(AppDelegate.ganttDisplaySmallLarge && AppDelegate->ganttviewcontroller.isCreatingNewBooking == NO)
		h=h*3;
	
	
    CGContextSaveGState(context);
	CGContextClipToRect (context, CGRectMake(0,HOURLINEYSTART,AppDelegate.ganttDisplayWidth, AppDelegate.ganttDisplayHeight-HOURLINEYSTART));
	int resourceCount=0;
    for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)// for all resources
		{
		if( (AppDelegate.ganttDisplaySelectedOnly == YES && AppDelegate->viewData.Resources[i].Selected == NO) ||
		   (AppDelegate->ganttviewcontroller.isCreatingNewBooking==YES && AppDelegate->viewData.Resources[i].includeInNewBookingView == NO) )
			{
			AppDelegate->viewData.Resources[i].pickRectangle = CGRectMake(0,0,1,1);		// Make unselectable
			AppDelegate->viewData.Resources[i].selectRectangle = CGRectMake(0,0,1,1);	// Make unselectable
			continue;																	// Don't draw
			}
		
		float thisResourceStartY = y;
		bool hasDrawnResource=false;
		// Draw bookings on resource
		for(size_t b=0;b<AppDelegate->viewData.Resources[i].bookings.size()   ;b++)
			{
			Date bStart = AppDelegate->viewData.Resources[i].bookings[b].FROM_TIME;
			Date bEnd = AppDelegate->viewData.Resources[i].bookings[b].TO_TIME;
			if( bStart.IsWithinRange(start,end) || bEnd.IsWithinRange(start,end)  || (bStart.IsEarlierThen(start) && bEnd.IsLaterThen(end)))
				{
				if(y > 0 && y < AppDelegate.ganttDisplayHeight) // higher then the current view
					{
					DrawBooking(rect, AppDelegate->viewData.Resources[i].bookings[b], y, h, context, colorspace, &AppDelegate->viewData.Resources[i].bookings[b].pickRectangle);
					// check doubleBooking
					for(size_t b2=b;b2<AppDelegate->viewData.Resources[i].bookings.size()   ;b2++)
						if(b!= b2)
							if( AppDelegate->viewData.Resources[i].bookings[b].overlaps(AppDelegate->viewData.Resources[i].bookings[b2]))  // doubleBooking
								{
								//y+= AppDelegate->viewData.Resources[i].Unfolded ? h : h/3; // room for overlap
								y+=h;
								break; // Stop looking for overlaps
								}
					}
				}
			}// for all bookings on resource
		// draw resource name
		if((AppDelegate->viewData.Resources[i].bookings.size() != 0 || AppDelegate.SettingsDisplayUnbookedResources ) || AppDelegate->viewData.Resources[i].RE_KEY == -1 )
			{
			hasDrawnResource=true;
			if(y > 15 && y < AppDelegate.ganttDisplayHeight) // within the current view on the Y axis
				{
				DrawBookingResource(rect, AppDelegate->viewData.Resources[i], y+h+4, h, context, colorspace, thisResourceStartY-4);
				}
			}
		if(hasDrawnResource)
			{
			y+= h+8;
			resourceCount++;
			}
		// Update picker rectangle for resource name
		AppDelegate->viewData.Resources[i].pickRectangle.size.height = y-thisResourceStartY;
		if(resourceCount%AppDelegate.ShowLineForEveryLine==0)// seperator line
			{
			CGContextSetLineWidth(context, 1.0);
			CGFloat dashArray[] = {2,2};
			CGContextSetLineDash(context, 0, dashArray, 2);
			CGContextMoveToPoint(context, 0, y-4);
			CGContextAddLineToPoint(context, AppDelegate.ganttDisplayWidth, y-4);
			CGContextSetStrokeColorWithColor(context, GREY_COLOR);
			CGContextStrokePath(context);
			CGContextSetLineDash(context, 0, NULL, 0);	// remove dash
			}
		}
	
	AppDelegate.ganttResourcesSizeY = y + AppDelegate.displayStartY;						// Needed for scroll-stop

	// update scrollview Y
	if(contentSizeNeedsUpadte)
		{
		CGSize newContentSize = invisibleScrollView.contentSize;
		newContentSize.height = y + AppDelegate.displayStartY;
		if(newContentSize.height != invisibleScrollView.contentSize.height)
			{
			invisibleScrollView.contentSize = newContentSize;
			NSLog(@"Contentsize:%f,%f", newContentSize.width, newContentSize.height);
			}
		contentSizeNeedsUpadte=NO;
		}
	
	CGContextRestoreGState(context);
	
	// Draw LEFT edge line
    CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, GREY_COLOR);
    CGContextMoveToPoint(context, RESOURCENAMEWIDTH, 0);
    CGContextAddLineToPoint(context, RESOURCENAMEWIDTH, rect.size.height);
    CGContextStrokePath(context);
	
    CGColorSpaceRelease(colorspace);
}



- (void)dealloc
{
	[selectedResourceImage release];
	selectedResourceImage=nil;
	
    [super dealloc];
}


- (IBAction)RequestResourceData
{
    cout << "Request Resource Data" << endl;
	NSString *request = [NSString stringWithFormat:@"SELECT * FROM  vw_my_resources WHERE (RV_KEY = %d OR RE_KEY = %d) AND SITE_KEY = %d AND IS_CURRENT=1 ORDER BY 3;", AppDelegate.SelectedCombination, AppDelegate->loginData.Login.RE_KEY, AppDelegate->loginData.Login.SITE_KEY];
	
	[AppDelegate.client executeQuery:request withDelegate:self];
}



@end



























