//
//  SplashView.m
//  iOdyssey
//
//  Created by kulitorum on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SplashView.h"
#import "iOdysseyAppDelegate.h"

@implementation SplashView

@synthesize progressView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	UIImage *img;
	cout << "drawRect" << endl;
	if(AppDelegate.IsIpad)
/*		if(AppDelegate.deviceOrientation == ORIENTATION_LANDSCAPE)
			img = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
		else*/
			img = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
	else
		img = [UIImage imageNamed:@"Default@2x.png"];
	[img drawInRect:rect];
}

@end
