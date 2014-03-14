//
//  AboutController.m
//  iOdyssey
//
//  Created by Kulitorum on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"

@implementation AboutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationDuration:2];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO]; 
	[self.navigationController popViewControllerAnimated:NO];
	[UIView commitAnimations];

	 //[self.navigationController popViewController:ANIMATED:YES];
}

@end
