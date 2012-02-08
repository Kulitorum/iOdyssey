//
//  MyBookingsController.h
//  iOdyssey
//
//  Created by Michael Holm on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookingDetailController.h"
#import "PreferencesController.h"
#include <vector>

using namespace std;

@interface MyBookingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	
    UITableView *table;
	UILabel *ResourceName;
	UILabel *DisplayScopeLabel;
	UILabel *UpdatedDateLabel;
	
	NSDateFormatter* DateAndTimeFormatter;
	NSDateFormatter* TimeFormatter;
	NSDateFormatter* ShortDateTimeFormatter;
	NSDateFormatter* DayNameFormatter;
	BookingDetailController *bookingDetailController;
	PreferencesController *preferencesController;
	UIViewController *aboutController;

	vector<int> BookingsPrDay;
}
-(void) RefreshView;

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet BookingDetailController *bookingDetailController;
@property (nonatomic, retain) IBOutlet PreferencesController *preferencesController;
@property (nonatomic, retain) IBOutlet UILabel *ResourceName;
@property (nonatomic, retain) IBOutlet UILabel *DisplayScopeLabel;
@property (nonatomic, retain) IBOutlet UIViewController *aboutController;
@property (nonatomic, retain) IBOutlet UILabel *UpdatedDateLabel;

-(IBAction) ShowAbout;
-(IBAction) ShowPreferences;
-(void) RecalcBookingsPrDayTable;

@end
