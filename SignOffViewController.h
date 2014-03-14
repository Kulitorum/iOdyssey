//
//  bookingDetailController.h
//  iOdyssey
//
//  Created by Michael Holm on 6/30/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Booking.h"
#import "Consumables.h"
#import "ConsumableCell.h"
#import "SqlClient.h"


@interface SignOffViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, SqlClientDelegate, UITextFieldDelegate>
{
	UITableView *table;
	UIBarButtonItem* addConsumableButton;
	Consumables *consumables;
	//	vector<ConsumableWithCount> items;
	UITextField *currentEditField;
	int runningCommandsCounter;
@public
	Booking *book;
}
-(IBAction) Return:(id)sender;
-(IBAction) Cancel:(id)sender;
-(IBAction) AddConsumable;
-(void)ConsumablesListReady:(NSNotification *)notification;

- (void)addHideKeyboardButtonToKeyboard:(id)sender;
- (void)keyboardWillShow:(id)sender;

@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) Booking *book;
@end
