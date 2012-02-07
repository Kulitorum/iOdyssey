//
//  UILabelWithTopbarBG.m
//  iOdyssey
//
//  Created by Kulitorum on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabelWithTopbarBG.h"

void drawGradientWithGloss(CGContextRef context, CGRect rect, CGColorRef startColor,  CGColorRef endColor);


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
	CGFloat bgColorTop[4] = { 11.0/255, 42.0/255, 85.0/255, 1.0 };
	CGFloat bgColorBottom[4] = { 11.0/255, 42.0/255, 85.0/255, 1.0 };
	CGColorRef BGColorTop = (CGColorRef)[(id)CGColorCreate(colorspace, bgColorTop) autorelease];	
	CGColorRef BGColorBottom = (CGColorRef)[(id)CGColorCreate(colorspace, bgColorBottom) autorelease];	
	CGContextSaveGState(context);
	drawGradientWithGloss(context, rect, BGColorTop,  BGColorBottom);

	CGColorSpaceRelease(colorspace);
	[super drawRect:rect];
}
@end
