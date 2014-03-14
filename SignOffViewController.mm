//
//  bookingDetailController.m
//  iOdyssey
//
//  Created by Michael Holm on 6/30/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "SignOffViewController.h"

#import "EditableDateCell.h"

#import "iOdysseyAppDelegate.h"

#include <vector>

#import "SqlResultSet.h"
#import "SqlClientQuery.h"


using namespace std;

@implementation SignOffViewController

@synthesize table, book;


// Externals
void FindResourcesForBookingID( int BO_KEY, NSMutableArray *result);


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)CloseBooking
{
	NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_UPDATE_BK_SIGNOFF @BO_KEY=%d, @USER=%@", book.BO_KEY, AppDelegate->loginData.loginName];
	[AppDelegate.client executeQuery:request withDelegate:self];
	NSLog(@"%@", request);

	[AppDelegate.ganttviewcontroller RefreshBookings];	// refresh
}


-(void) SignOff
{
    // Add Consumables
    NSEnumerator * S = [consumables->ServiceGroups objectEnumerator];
	SCG* s;

	runningCommandsCounter = 0;
	
	while(s = [S nextObject])
    {
		NSEnumerator * I = [s->items objectEnumerator];
		Consumable* i;
		while(i = [I nextObject])
        {
		if(i->newQTY != i->QTY)
			{
			NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_UPDATE_SERVICES @BO_KEY=%d, @SC_KEY=%d, @QTY=%d", book.BO_KEY, i->SC_KEY, i->newQTY];
			NSLog(@"%@", request);
			[AppDelegate.client executeQuery:request withDelegate:self];
			runningCommandsCounter++;
			}
        }
    }
	// IOS_UPDATE_ACTUALS BS_KEY FROM_TIME TO_TME
	NSMutableArray *bookings = [[NSMutableArray alloc] init];
	FindResourcesForBookingID(book.BO_KEY, bookings);
	for(Booking* b in bookings)
		{
		NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_UPDATE_ACTUALS @BS_KEY=%d, @ACT_FROMTIME='%@', @ACT_TOTIME='%@'", b.BS_KEY, b.FROM_TIME.FormatForSQLWithTime(), b.TO_TIME.FormatForSQLWithTime()];
		NSLog(@"%@", request);
		[AppDelegate.client executeQuery:request withDelegate:self];
		}

	DLog(@"*********************************************************************************************\n           WARNING: Signing off boooking without using GUI actuals time\n*********************************************************************************************");
	
	if(runningCommandsCounter == 0)
		[self CloseBooking];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	//SC_KEY SC_NAME IS_CURRENT SITE_KEY UNIT SC_ID BO_KEY PI_NAME 
	
	cout << "Got SignOff Data, Processing" << endl;
//	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
		if(runningCommandsCounter == -1) // just signed it off
			{
			[AppDelegate.ganttviewcontroller RefreshBookings];
			return;
			}
		runningCommandsCounter--;
		if(runningCommandsCounter == 0)
			{
			cout << "Done updating consumable quantities, signing booking off" << endl;
			runningCommandsCounter--;// -1 = signoff
			[self CloseBooking];
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error signing off booking" message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		}
//	DLog(@"%@", outputString);
}



-(IBAction) Return:(id)sender
{
	[self SignOff];

	if(self.navigationController == nil)                     // if we are in a modal view
		{
		// if we are in portrait mode, don't animate
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		
		if(orientation == UIDeviceOrientationPortrait || orientation==UIDeviceOrientationPortraitUpsideDown)
			{
			[self dismissModalViewControllerAnimated :NO];
			}
		else
			{
			[self dismissModalViewControllerAnimated :YES];
			}
		
		}
	else
		{
		AppDelegate.lastViewedBookingKey = book.BS_KEY;
		[self.navigationController popViewControllerAnimated:YES];// Tell detail view ontroller to stand back
		[AppDelegate.myBookingsController RefreshView];
		}
}
-(IBAction) Cancel:(id)sender
{
	if(self.navigationController == nil)                     // if we are in a modal view
		{
		// if we are in portrait mode, don't animate
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		
		if(orientation == UIDeviceOrientationPortrait || orientation==UIDeviceOrientationPortraitUpsideDown)
			{
			[self dismissModalViewControllerAnimated :NO];
			}
		else
			[self dismissModalViewControllerAnimated :YES];
		
		}
	else
		{
		//		AppDelegate.lastViewedBookingKey = book.BS_KEY;
		//[self.navigationController popTotheNewBookingControlllerAnimated:YES];// Tell detail view ontroller to stand back
		//		[AppDelegate.myBookingsController RefreshView];
		[self.navigationController popViewControllerAnimated:YES];// Tell detail view ontroller to stand back
		}
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	currentEditField = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
		// If called from the gantt view, remove the add comment button
	consumables = [[Consumables alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ConsumablesListReady:) 
												 name:@"ConsumablesReadyNotification"
											   object:nil];
	
	[consumables RequestConsumableData:book.BO_KEY];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];

	currentEditField = nil;
    
	[table scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}


-(void)viewDidAppear:(BOOL)animated
{
	cout << " Signof view controller :: viewDidAppear" << endl;
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;//(UIInterfaceOrientationIsPortrait(interfaceOrientation));
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *bookings = [[NSMutableArray alloc] init];
	FindResourcesForBookingID(book.BO_KEY, bookings);
	int count = [bookings count];
	bookings=nil;
    if(indexPath.section < count)
        {
            if(AppDelegate.IsIpad)
                return 65;	// start, end
            else
                return 55;
        }
	return 40;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return -4;
}
*/


-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSMutableArray *bookings = [[NSMutableArray alloc] init];
	FindResourcesForBookingID(book.BO_KEY, bookings);
	int count = [bookings count];
    if(section < count)
        return 2;	// start, end

	int serviceGroupNr = section-count;

	return [((SCG*)[consumables->ServiceGroups objectAtIndex:serviceGroupNr])->items count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSMutableArray *bookings = [[NSMutableArray alloc] init];
	FindResourcesForBookingID(book.BO_KEY, bookings);
	int count = [bookings count];
	return count+[consumables->ServiceGroups count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
	NSMutableArray *bookings = [[NSMutableArray alloc] init];
	FindResourcesForBookingID(book.BO_KEY, bookings);
	
	if(section < [bookings count])// compiled name of resource if we are displaying a resource
	   {
	   Booking* b = ((Booking*)[bookings objectAtIndex:section]);
	   if( [b.TYPE compare:@"S"] == NSOrderedSame)
		   {
		   NSString* result = [[b.FIRST_NAME stringByAppendingString:@" "] stringByAppendingString:b.LAST_NAME];
		   return result;
		   }
	   NSString* result = b.Resource;
	   return result;
	   }
	
	int serviceGroupNr = section-[bookings count];
	if(consumables->ServiceGroups == nil)
		return @"";
	
	return ((SCG*)[consumables->ServiceGroups objectAtIndex:serviceGroupNr])->SCG_NAME;
	
   return @"Consumables";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *bookings = [[NSMutableArray alloc] init];
	FindResourcesForBookingID(book.BO_KEY, bookings);
	
//	cout << "Cell:" << indexPath.section << ", " << indexPath.row << " of " << bookings.size() << "Bookings" << endl;
	
	if(indexPath.section < [bookings count] )
		{
		EditableDateCell *cell;
		if(AppDelegate.IsIpad)
			cell = (EditableDateCell *)[table dequeueReusableCellWithIdentifier:@"EditableDateCell_ID_iPad"];
		else
			cell = (EditableDateCell *)[table dequeueReusableCellWithIdentifier:@"EditableDateCell_ID"];
		if (cell == nil)
			{
			DLog(@"New EditableDateCell Made");
			
			NSString *nibName;
			if(AppDelegate.IsIpad)
				nibName = @"EditableDateCell_iPad";
			else
				nibName = @"EditableDateCell_iphone";
			
			NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
			for(id currentObject in topLevelObjects)
				{
				if([currentObject isKindOfClass:[EditableDateCell class]])
					{
					cell = (EditableDateCell *)currentObject;
					break;
					}
				}
			}
		
		Booking* b = ((Booking*)[bookings objectAtIndex:indexPath.section]);
		
		switch(indexPath.row)
			{
				case 0:	// EditableDateCell start
				[[cell Title] setText:@"Start"];
				[[cell dateLabel] setText: b.FROM_TIME.FormatForSignOffController() ];
				[cell setDate:[b fromTimePtr]];
				break;
				case 1:	// EditableDateCell start
				[[cell Title] setText:@"End"];
				[[cell dateLabel] setText: b.TO_TIME.FormatForSignOffController() ];
				[cell setDate:[b toTimePtr]];
				break;
			}
		return cell;
		}
	
	static NSString *CellIdentifier = @"ConsumableCell";
	ConsumableCell *cell = (ConsumableCell *)[table dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		{
		//			DLog(@"New Cell Made");
		
		NSString *nibName;
/*		if(AppDelegate.IsIpad)
			nibName = @"TextInputCell_ipad";
		else*/
			nibName = @"ConsumableCell";
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
		for(id currentObject in topLevelObjects)
			{
			if([currentObject isKindOfClass:[UITableViewCell class]])
				{
				cell = (ConsumableCell *)currentObject;
				break;
				}
			}
		}
	//	[[cell name] setText:@"qwe"];
	if(consumables == nil || consumables->ServiceGroups == nil)
		{
		return cell;
		}

	int serviceGroupNr = indexPath.section-[bookings count];
	SCG* S = ((SCG*)[consumables->ServiceGroups objectAtIndex:serviceGroupNr]);

	id obj = [S->items objectAtIndex:indexPath.row];
	Consumable *asd = (Consumable*)obj;
	[[cell name ]setText: asd->SC_NAME];
	[[cell amount]setText:[NSString stringWithFormat:@"%d", asd->QTY]];
    if([asd->UNIT isKindOfClass:[NSString class]])
        [[cell unit ]setText: asd->UNIT];
    else
        [[cell unit ]setText: @""];

	cell.whereToPutTheNumber = &asd->newQTY;
	
	CGRect textFieldFrame = cell.amount.frame;
	CGRect newTextFieldFrame = CGRectMake(textFieldFrame.origin.x, textFieldFrame.origin.y+6, textFieldFrame.size.width, textFieldFrame.size.height-12);
	[cell amount].frame = newTextFieldFrame;

	cell.amount.delegate = self;
	
    return cell;

}

-(IBAction) AddConsumable
{
	AppDelegate->addCommentViewController.book = self.book;
	[self.navigationController pushViewController:AppDelegate->addCommentViewController animated:YES];
}

-(void)ConsumablesListReady:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"ConsumablesReadyNotification"])
        DLog (@"Successfully received the ConsumablesListReady!");
	
	[table reloadData];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	currentEditField = textField;
}
- (void)doneButton:(id)sender 
{
	[currentEditField resignFirstResponder];
	currentEditField = nil;
}

- (void)keyboardWillShow:(id)sender
{
	// We must perform on delay (schedules on next run loop pass) for the keyboard subviews to be present.
	[self performSelector:@selector(addHideKeyboardButtonToKeyboard:) withObject:nil afterDelay:0];
}

- (void)addHideKeyboardButtonToKeyboard:(id)sender
{
	// Locate non-UIWindow.
	UIWindow *keyboardWindow = nil;
	for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
		if (![[testWindow class] isEqual:[UIWindow class]]) {
			keyboardWindow = testWindow;
			break;
		}
	}
	if (!keyboardWindow) return;
	
	// Locate UIKeyboard.
	UIView *foundKeyboard = nil;
	for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
		
		// iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
		if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
			possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
		}
		
		if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
			foundKeyboard = possibleKeyboard;
			break;
		}
	}
	
	if (foundKeyboard) {
		// create custom button
		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		doneButton.frame = CGRectMake(0, 163, 106, 53);
		doneButton.adjustsImageWhenHighlighted = NO;
		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
		// Add the button to foundKeyboard.
		[foundKeyboard addSubview:doneButton];
	}
	
}
/*
- (void)createSystemClickSound {
	CFBundleRef mainBundle;
	mainBundle = CFBundleGetMainBundle ();
	soundFileURLRef  =	CFBundleCopyResourceURL (mainBundle, CFSTR ("Tock"), CFSTR ("caf"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
}

- (void)buildButton {
	self.periodButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.periodButton.adjustsImageWhenHighlighted = NO;
	[self.periodButton setImage:[UIImage imageNamed:@"periodButtonUp.png"] forState:UIControlStateNormal];
	[self.periodButton setImage:[UIImage imageNamed:@"periodButtonDown.png"] forState:UIControlStateHighlighted];
	[self.periodButton addTarget:self action:@selector(periodButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.periodButton addTarget:self action:@selector(playClickSound:) forControlEvents:UIControlEventTouchDown];
	self.periodButton.frame = CGRectMake(0, 163, 105, 53);
	[self createSystemClickSound];
}

// play system click sound created before
- (void)playClickSound:(id)sender {
	AudioServicesPlaySystemSound (self.soundFileObject);
}

- (void)periodButtonClicked:(id)sender {
	// do whatever you want when the button is pressed
}
 */
@end



























