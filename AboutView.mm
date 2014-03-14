//
//  AboutView.m
//  iOdyssey
//
//  Created by Kulitorum on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutView.h"
#include <iostream>
#include "iOdysseyAppDelegate.h"

using namespace std;

@implementation AboutView

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
    }

	timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(clockTick) userInfo:nil repeats:YES];

	if(AppDelegate.IsIpad)
		ypos = 1024;
	else
		ypos = 480;
	
	return self;
}

-(void)clockTick
{
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

	UIImage *img;
	
	if(AppDelegate.IsIpad)
		img = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
	else
		img = [UIImage imageNamed:@"Default@2x.png"];
	
	[img drawInRect:rect];
	
	ypos--;

	CGRect textrect = CGRectMake(rect.origin.x, ypos, rect.size.width, rect.size.height);
	
	NSString *str = @"iOdyssey by Michael Holm\nwww.Kulitorum.com\nCopyright 2011 2xB Systems SARL\n\n\n\n\n\n\n\n\nTouch screen to return";
	[str drawInRect:textrect withFont:[UIFont fontWithName:@"Helvetica" size:11 ] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];

	UIImage *img2;
	if(AppDelegate.IsIpad)
		img2 = [UIImage imageNamed:@"Default-Portrait-ipad_alpha.png"];
	else
		img2 = [UIImage imageNamed:@"Default@2x_alpha.png"];

	[img2 drawInRect:rect];

	if(AppDelegate.IsIpad)
        {
        if(ypos < 620)
            ypos = 1024;
        }
	else if(ypos < 160)
        ypos = 480;
}

@end
