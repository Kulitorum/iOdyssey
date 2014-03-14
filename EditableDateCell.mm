//
//  DateCell.m
//  iOdyssey
//
//  Created by Michael Holm on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditableDateCell.h"
#import "iOdysseyAppDelegate.h"


@implementation EditableDateCell
@synthesize Title, dateLabel, bookedDateLabel, date;
@synthesize timeSlider;

CGPoint firstTouchPosition;

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

-(void) setDate:(Date *)thedate
{
	date=thedate;
	if(thedate != nil)
		{
		[timeSlider setCellToChange:self];
		[bookedDateLabel setText:date->FormatForSignOffController()];
		}
}
-(void) refreshLabel
{
	[dateLabel setText:date->FormatForSignOffController()];
}


@end
