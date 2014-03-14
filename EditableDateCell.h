//
//  DateCell.h
//  iOdyssey
//
//  Created by Michael Holm on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Date.h"
#import "TimeSlider.h"

@interface EditableDateCell : UITableViewCell {
	IBOutlet UILabel *Title;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *infoLabel;
	Date *date;
}

@property (nonatomic) IBOutlet TimeSlider *timeSlider;
@property (nonatomic) IBOutlet UILabel *Title;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *bookedDateLabel;
@property (nonatomic, assign) Date *date;

-(void) refreshLabel;

@end
