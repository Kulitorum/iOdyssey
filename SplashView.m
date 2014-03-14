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
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		if ([UIScreen mainScreen].scale == 2.0f) {
			CGSize result = [[UIScreen mainScreen] bounds].size;
			CGFloat scale = [UIScreen mainScreen].scale;
			result = CGSizeMake(result.width * scale, result.height * scale);
			
			if(result.height == 960){
				//NSLog(@"iPhone 4, 4s Retina Resolution");
				img = [UIImage imageNamed:@"Default@2x.png"];
			}
			if(result.height == 1136){
				//NSLog(@"iPhone 5 Resolution");
				img = [UIImage imageNamed:@"Default-568h@2x.png"];

			}
		} else {
			//NSLog(@"iPhone Standard Resolution");
			img = [UIImage imageNamed:@"Default@2x.png"];
		}
	} else {
		if ([UIScreen mainScreen].scale == 2.0f) {
			//NSLog(@"iPad Retina Resolution");
			img = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
		} else{
			//NSLog(@"iPad Standard Resolution");
			img = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
		}
	}
	
	[img drawInRect:rect];
}

@end
