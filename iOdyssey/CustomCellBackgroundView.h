//
//  CustomCellBackgroundView.h
//
//  Created by Mike Akers on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Booking.h"

typedef enum  {
    CustomCellBackgroundViewPositionTop, 
    CustomCellBackgroundViewPositionMiddle, 
    CustomCellBackgroundViewPositionBottom,
    CustomCellBackgroundViewPositionSingle
} CustomCellBackgroundViewPosition;

@interface CustomCellBackgroundView : UIView {
    UIColor *borderColor;
    UIColor *fillColor;
    UIColor *progressColor;
	UIColor *passedBookingsColor;
	UIColor *openPassedBookingsColor;
    CustomCellBackgroundViewPosition position;
	Booking *book;
	float progress;
}

@property(nonatomic, retain) UIColor *borderColor, *fillColor, *progressColor, *passedBookingsColor, *openPassedBookingsColor;
@property(nonatomic) Booking *book;
@property(nonatomic) CustomCellBackgroundViewPosition position;
@property(nonatomic) float progress;
@end

