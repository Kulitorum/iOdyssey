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

@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) IBOutlet BookingDetailController *bookingDetailController;
@property (nonatomic) IBOutlet PreferencesController *preferencesController;
@property (nonatomic) IBOutlet UILabel *ResourceName;
@property (nonatomic) IBOutlet UILabel *DisplayScopeLabel;
@property (nonatomic) IBOutlet UIViewController *aboutController;
@property (nonatomic) IBOutlet UILabel *UpdatedDateLabel;

-(IBAction) ShowAbout;
-(IBAction) ShowPreferences;
-(void) RecalcBookingsPrDayTable;

@end
