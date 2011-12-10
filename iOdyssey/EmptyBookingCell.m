//
//  EmptyBookingCell.m
//  iOdyssey
//
//  Created by kulitorum on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmptyBookingCell.h"

@implementation EmptyBookingCell

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

- (void)drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	// Graded background
	size_t num_locations = 2;
	CGFloat locations[2] = {0.0, 1.0};
	CGFloat components[8] = {0.4f, 0.7f, 0.4f, 1.0, // Bottom Colour: Red, Green, Blue, Alpha.
		1.0f, 1.0f, 1.0f, 1.0f}; // Top Colour: Red, Green, Blue, Alpha.
	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	
	CGPoint startPoint, endPoint;
	startPoint.x = 0.0;
	startPoint.y = self.frame.size.height;
	endPoint.x = 0.0;
	endPoint.y = 0.0;
	CGContextDrawLinearGradient (c, myGradient, startPoint, endPoint, 0);
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(myColorspace);
}

@end
