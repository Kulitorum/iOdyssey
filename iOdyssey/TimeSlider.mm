//
//  BJRangeSliderWithProgress.m
//  BJRangeSliderWithProgress
//
//  Created by Barrett Jacobsen on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimeSlider.h"
#import "EditableDateCell.h"
#import "iOdysseyAppDelegate.h"

@implementation TimeSlider

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];

        [gesture setTranslation:CGPointZero inView:self];
		offsetInPixels += translation.x;
		[self updateHoursLabel];
		
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)setCellToChange:(EditableDateCell*)cell
{
	cellToChange=cell;

	// get the hours as a float
	originalDate = *cellToChange.date;
	timeInpixels = (originalDate.HourValueAsFloat() * sizeOfAnHour);
	CGPoint offset = CGPointMake(timeInpixels, 0);
	labelView.contentOffset=offset;
	daysOffset=0;
	[self updateHoursLabel];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if( decelerate == NO)
		[self scrollViewDidEndDecelerating:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGPoint offset = labelView.contentOffset;
	
	float xpos = offset.x;
	int pos=(xpos+12.5f)/25.0;
	xpos = pos*25;
	offset.x = xpos;
	// Animate transition to instruction view
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
	labelView.contentOffset = offset;
    [UIView commitAnimations];
}

-(void) updateHoursLabel
{
	CGPoint offset = labelView.contentOffset;
	bool changed=NO;
	while(offset.x < 0)
		{
		offset.x += sizeOfAnHour*24;
		daysOffset++;
		changed=YES;
		}
	while(offset.x > sizeOfAnHour*24)
		{
		offset.x -= sizeOfAnHour*24;
		daysOffset--;
		changed=YES;
		}
	if(changed)
		{
		[labelView setContentOffset:offset animated:NO];
		[labelView setNeedsDisplay];
		}
	
	float pixelOffset = timeInpixels-labelView.contentOffset.x;
	// set the time.
	if(cellToChange && cellToChange.date)
		{
		*cellToChange.date = originalDate.MinutesBefore( ((float)pixelOffset/(float)sizeOfAnHour*60) + daysOffset*60*24 );
		[cellToChange refreshLabel];
		}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSLog(@"- (void)scrollViewDidScroll:(UIScrollView *)scrollView;  ");
	[self updateHoursLabel];
}

- (void)setup
{
	if(AppDelegate->IsIpad)
		BGImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimeAdjusterUnder_iPad.png"]];
	else
		BGImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimeAdjusterUnder.png"]];
    [self addSubview:BGImage];
	labelView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
	[self updateHoursLabel];
	
	if(AppDelegate->IsIpad)
		ClockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UR_iPad.png"]];
	else
		ClockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UR.png"]];
	sizeOfAnHour = 100.0f;
	[labelView addSubview:ClockImage];
	[labelView setContentSize:CGSizeMake(2500, self.frame.size.height)];
    [labelView setShowsHorizontalScrollIndicator:NO];
	[labelView setDelegate:self];
	[self addSubview:labelView];
	
	if(AppDelegate->IsIpad)
		FGImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimeAdjusterOver_iPad.png"]];
	else
		FGImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimeAdjusterOver.png"]];
  [self addSubview:FGImage];
	
	//disables the built-in pan gesture
	/*	for (UIGestureRecognizer *gesture in labelView.gestureRecognizers){
	 if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
	 gesture.enabled = NO;
	 }
	 }
	 */	
	
	UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:leftPan];
	
	timeInQuartersSinceMidnight = 4*12;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
	[BGImage release];
	[FGImage release];
	[hoursLabel release];
	[labelView release];
}

@end
