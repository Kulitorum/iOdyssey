//
//  UILabelWithTopbarBG.m
//  iOdyssey
//
//  Created by Kulitorum on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabelWithTopbarBG.h"

void drawGradientWithGloss(CGContextRef context, CGRect rect, UIColor *startColor,  UIColor *endColor);


@implementation UILabelWithTopbarBG

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
	//	iOdysseyAppDelegate* app=((iOdysseyAppDelegate *)[UIApplication sharedApplication].delegate);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	
	// Datebar (top bar) background
    UIColor *BGColorTop = [UIColor colorWithRed:11.0/255 green:42.0/255 blue:85.0/255 alpha:0.1];
	CGContextSaveGState(context);
	drawGradientWithGloss(context, rect, BGColorTop,  BGColorTop);

	CGColorSpaceRelease(colorspace);
	[super drawRect:rect];
}
@end
