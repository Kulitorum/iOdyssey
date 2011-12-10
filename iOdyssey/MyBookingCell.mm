//
//  MyBookingCell.m
//  iOdyssey
//
//  Created by Michael Holm on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyBookingCell.h"
#import "iOdysseyAppDelegate.h"

@implementation MyBookingCell

@synthesize StartTime, EndTime, Component, Client, Project, Activity, DayLabel, DateLabel, STATUS, book, signedOffImage;
/*
- (void)drawRect:(CGRect)rect
{
    if(book == nil)
        return;
    
	[super drawRect:rect];
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	// Graded background
	size_t num_locations = 2;
	CGFloat locations[2] = {0.0, 1.0};
	CGFloat components[8] = {0.8f, 0.8f, 0.8f, 1.0, // Bottom Colour: Red, Green, Blue, Alpha.
		1.0f, 1.0f, 1.0f, 1.0f}; // Top Colour: Red, Green, Blue, Alpha.

		// when are we?
	NSDate* a = [NSDate date];
	Date now(a);
	if(book->endsBefore(now))
		{
		if ([self isHighlighted] || [self isSelected])
			{
			components[0] = 0.4f;
			components[1] = 0.4f;
			components[2] = 0.8f;
			components[3] = 1.0f;
			components[4] = 0.6f;
			components[5] = 0.6f;
			components[6] = 0.8f;
			components[7] = 1.0f;
			}
		else
			{
			components[0] = 0.6f;
			components[1] = 0.6f;
			components[2] = 0.6f;
			components[3] = 1.0f;
			components[4] = 0.8f;
			components[5] = 0.8f;
			components[6] = 0.8f;
			components[7] = 1.0f;
			}
		}
	else	if ([self isHighlighted] || [self isSelected])
		{
		components[0] = 0.8f;
		components[1] = 0.8f;
		components[2] = 1.8f;
		components[3] = 1.0f;
		components[4] = 1.0f;
		components[5] = 1.0f;
		components[6] = 1.0f;
		components[7] = 1.0f;
		}

	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	
	CGPoint startPoint, endPoint;
	startPoint.x = 0.0;
	startPoint.y = self.frame.size.height;
	endPoint.x = 0.0;
	endPoint.y = 0.0;
//	CGContextDrawLinearGradient (c, myGradient, startPoint, endPoint, 0);
	
	// Indicate passed time
	if(book->overlaps(now))
		{
		CGGradientRef myGradient;
		// Graded background
		size_t num_locations = 2;
		CGFloat locations[2] = {0.0, 1.0};
		CGFloat components[8] = {0.4f, 0.7f, 0.4f, 1.0f, // Bottom Colour: Red, Green, Blue, Alpha.
			0.6f, 1.0f, 0.6f, 1.0}; // Top Colour: Red, Green, Blue, Alpha.
		
		myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
		
		CGPoint startPoint, endPoint;
		startPoint.x = 0.0;
		startPoint.y = self.frame.size.height;
		endPoint.x = 0.0;
		endPoint.y = 0.0;
		CGContextSaveGState (c);

		CGRect rectangle = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			
		// t.....
		float t = (now-book->FROM_TIME).nstimeInterval()/(book->TO_TIME.nstimeInterval() - book->FROM_TIME.nstimeInterval());
		
		rectangle.size.width = rectangle.size.width*t;
		CGContextClipToRect (c, rectangle);
		CGContextDrawLinearGradient (c, myGradient, startPoint, endPoint, 0);
		CGGradientRelease(myGradient);
		CGContextRestoreGState (c);
		}	

	const CGFloat topSepColor[] = { 0.0f, 0.0f, 0.0f, 1.0f }; // Cell Seperator Colour - Top
	
	CGGradientRelease(myGradient);
	
	CGContextSetStrokeColor(c, topSepColor);
	CGColorSpaceRelease(myColorspace);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}
 */

@end
