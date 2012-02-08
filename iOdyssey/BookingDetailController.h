//
//  bookingDetailController.h
//  iOdyssey
//
//  Created by Michael Holm on 6/30/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Booking.h"

@interface BookingDetailController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
	UITableView *table;
	UIBarButtonItem* addCommentButton;
@public
	Booking *book;
}
-(IBAction) Return:(id)sender;
-(IBAction) AddComment;
-(IBAction) ShowSignOffViewController;

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *signOffButton;
@property (nonatomic, retain) Booking *book;
@end
