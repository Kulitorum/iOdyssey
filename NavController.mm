//
//  NavController.m
//  iOdyssey
//
//  Created by Michael Holm on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include <iostream>
#import "NavController.h"
#import "iOdysseyAppDelegate.h"

using namespace std;

@implementation NavController

@synthesize activityIndicator, navBar, myBookingsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
		{
		if ([UIView instancesRespondToSelector:@selector(addGestureRecognizer:)])
			{
			UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(navBarSwipeDetected:)];
			swiper.direction = UISwipeGestureRecognizerDirectionRight;
			swiper.numberOfTouchesRequired = 1;
			[self.navigationController.navigationBar addGestureRecognizer:swiper];
			swiper.direction = UISwipeGestureRecognizerDirectionLeft;
			[self.navigationController.navigationBar addGestureRecognizer:swiper];
			}
	    }
    return self;
}

// New Autorotation support.
- (BOOL)shouldAutorotate
{
	[UIView setAnimationsEnabled: NO];
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	navBar.topItem.title = @"My bookings";
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
*/
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	switch (toInterfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
		break;
		
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		[self dismissModalViewControllerAnimated:NO];
		break;
	}
}

@end
