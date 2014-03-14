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

@property (nonatomic) IBOutlet UIImageView *signedOffImage;
@property (nonatomic) IBOutlet UILabel *StartTime;
@property (nonatomic) IBOutlet UILabel *EndTime;
@property (nonatomic) IBOutlet UILabel *Component;
@property (nonatomic) IBOutlet UILabel *Client;
@property (nonatomic) IBOutlet UILabel *Project;
@property (nonatomic) IBOutlet UILabel *Activity;
@property (nonatomic) IBOutlet UILabel *DayLabel;
@property (nonatomic) IBOutlet UILabel *DateLabel;
@property CStatus STATUS;
@property (nonatomic) Booking *book;
@end