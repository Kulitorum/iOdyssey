//
//  ganttScrollView.m
//  iOdyssey
//
//  Created by Michael Holm on 12/10/11.
//  Copyright (c) 2011 Kulitorum. All rights reserved.
//

#import "GanttScrollView.h"
#import "iOdysseyAppDelegate.h"
#import <UIKit/UIGestureRecognizer.h>

@implementation GanttScrollView



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"GanttScrollView:touchesBegan");
	if(AppDelegate->newBookingControlller.isCreatingNewBooking == NO)
		[super touchesBegan:touches withEvent:event];
	[localDelegate touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"GanttScrollView:touchesBegan");
	if(AppDelegate->newBookingControlller.isCreatingNewBooking == NO)
		[super touchesMoved:touches withEvent:event];
	[localDelegate touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"GanttScrollView:touchesBegan");
	if(AppDelegate->newBookingControlller.isCreatingNewBooking == NO)
		[super touchesEnded:touches withEvent:event];
	[localDelegate touchesEnded:touches withEvent:event];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
		if([otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
			return NO;
	return YES;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
	// workaround for bug: pinch recognizer gets added during rotation,
	//  causes contentOffset to be set to (0,0) on pinch
	if ([gestureRecognizer isKindOfClass:[NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer") class]])
		{
		NSLog(@"UIScrollViewPagingSwipeGestureRecognizer");
		UIScrollViewPagingSwipeGestureRecognizer = gestureRecognizer;
		}
	
//	UIScrollViewDelayedTouchesBeganGestureRecognizer
//	UIScrollViewPanGestureRecognizer
//	UIScrollViewPinchGestureRecognizer
//	UIScrollViewPagingSwipeGestureRecognizer

	[super addGestureRecognizer:gestureRecognizer];
}
-(void) setDelegate:(id<UIScrollViewDelegate>)delegate
{
	[super setDelegate:delegate];
	localDelegate = delegate;
}

@end
