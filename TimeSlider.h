//
//  BJRangeSliderWithProgress.h
//  BJRangeSliderWithProgress
//
//  Created by Barrett Jacobsen on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Date.h"

@class EditableDateCell;

typedef enum {
    BJRSWPAudioRecordMode = 0,
    BJRSWPAudioSetTrimMode,
    BJRSWPAudioPlayMode,

} BJRangeSliderWithProgressDisplayMode;

@interface TimeSlider : UIControl <UIScrollViewDelegate>
{

    UIImageView *BGImage;
    UIImageView *FGImage;
	UIImageView *ClockImage;
	
	UILabel *hoursLabel;
	UIScrollView *labelView;
    
	float sizeOfAnHour;
	
	float timeInQuartersSinceMidnight;
	float timeInpixels;
	float offsetInPixels;
	int daysOffset;
	Date originalDate;
@public
	EditableDateCell *cellToChange;
}


-(void)updateHoursLabel;
-(void)setCellToChange:(EditableDateCell*)cell;

@end
