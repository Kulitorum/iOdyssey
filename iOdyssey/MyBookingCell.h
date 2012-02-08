//
//  MyBookingCell.h
//  iOdyssey
//
//  Created by Michael Holm on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Booking.h"

@interface MyBookingCell : UITableViewCell
{
	Booking *book;
	IBOutlet UILabel *StartTime;
	IBOutlet UILabel *EndTime;
	IBOutlet UILabel *Component;
	IBOutlet UILabel *Client;
	IBOutlet UILabel *Project;
	IBOutlet UILabel *Activity;
	IBOutlet UILabel *DayLabel;
	IBOutlet UILabel *DateLabel;
	CStatus STATUS;
	
}

@property (nonatomic, retain) IBOutlet UIImageView *signedOffImage;
@property (nonatomic, retain) IBOutlet UILabel *StartTime;
@property (nonatomic, retain) IBOutlet UILabel *EndTime;
@property (nonatomic, retain) IBOutlet UILabel *Component;
@property (nonatomic, retain) IBOutlet UILabel *Client;
@property (nonatomic, retain) IBOutlet UILabel *Project;
@property (nonatomic, retain) IBOutlet UILabel *Activity;
@property (nonatomic, retain) IBOutlet UILabel *DayLabel;
@property (nonatomic, retain) IBOutlet UILabel *DateLabel;
@property CStatus STATUS;
@property (nonatomic, retain) Booking *book;
@end