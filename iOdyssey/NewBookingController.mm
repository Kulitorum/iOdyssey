//
//  NewBookingController.m
//  iOdyssey
//
//  Created by Kulitorum on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewBookingController.h"
#import "iOdysseyAppDelegate.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"

/*
 EXEC  [dbo].[BOOKING_CREATE]
  @CL_KEY = 9130,	// client
  @PR_KEY = 311704,	// Project
  @WO_KEY = 85291,	// // 
  @AC_KEY = 78,		//
  @FROM_TIME = N'2011-09-26 09:00',
  @TO_TIME = N'2011-09-26 19:00',
  @SITE_KEY = 9999,
  @KeyList = N'101,109'  -- RE_KEYS for booking slots
 */
@implementation ResourceAndTime

@synthesize RE_KEY;
@synthesize RE_NAME;
@synthesize FROM_TIME;
@synthesize TO_TIME;


-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

@end



@implementation NewBookingController
@synthesize ClientButton;
@synthesize ProjectButton;
@synthesize FolderButton;
@synthesize FolderRemarksTextView;
@synthesize bookingRemarkView;
@synthesize confirmBookingButton;

-(BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
	[theTextField resignFirstResponder];
	return YES;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
	CL_KEY=0;
	PR_KEY=0;
	WO_KEY=0;
	AC_KEY=30;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserPickedClient:) name:@"userPickedClient" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserPickedProject:) name:@"userPickedProject" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserPickedFolder:) name:@"userPickedFolder" object:nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight || interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}



#pragma mark -
#pragma mark Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
/*	textView.text = @"";	// clear edit field
	
    if (textView.inputAccessoryView == nil)
		{
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = accessoryView;
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
		}
*/    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
/*    
    
    // Reduce the size of the text view so that it's not obscured by the keyboard.
    // Animate the resize so that it's in sync with the appearance of the keyboard.
 	
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    textView.frame = newTextViewFrame;
	
    [UIView commitAnimations];
*/
}


- (void)keyboardWillHide:(NSNotification *)notification {
/*    
    NSDictionary* userInfo = [notification userInfo];
    
	
    // Restore the size of the text view (fill self's view).
    // Animate the resize so that it's in sync with the disappearance of the keyboard.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    textView.frame = self.view.bounds;
    
    [UIView commitAnimations];
*/
 }

-(IBAction) ShowClientPicker:(id)sender
{
	[self presentModalViewController:AppDelegate.clientSearchController animated:YES];
}
-(IBAction) ShowProjectPicker:(id)sender
{
#ifdef ALLOW_NO_PROJECT_AND_FOLDER
	if(AppDelegate->projectData->projects.size() == 0)
		{
		ProjectInfo C;
		C.PR_KEY = -1;
		C.PR_NAME = @"No Project selected";
		AppDelegate->projectData->projects.push_back(C);
		}
#endif
	[self presentModalViewController:AppDelegate.projectData animated:YES];
}
-(IBAction) ShowFolderPicker:(id)sender
{
#ifdef ALLOW_NO_PROJECT_AND_FOLDER
	if(AppDelegate->folderData->folders.size() == 0)
		{
		FolderInfo C;
		C.WO_KEY = -100;
		C.NAME = @"No Folder selected";
		AppDelegate->folderData->folders.push_back(C);
		}
#endif
	[self presentModalViewController:AppDelegate.folderData animated:YES];
}


-(void)UserPickedClient:(NSNotification *)notification
{
	NSString *pickedClient = (NSString *) [notification object]; 
	
	DLog(@"NewBookingController: %@ picked", pickedClient);

	[ClientButton setTitle:pickedClient forState:UIControlStateNormal];

	
	// Find client ID
	CL_KEY=0;
	for(int i=0;i<[AppDelegate.clientData Count];i++)
		{
		ClientInfo *C = [AppDelegate.clientData GetClientByIndex:i];
		if([pickedClient compare:C->CL_NAME] == NSOrderedSame)
			{
			CL_KEY = C->CL_KEY;
			break;
			}
		}
	if(CL_KEY != 0)
		{
		[AppDelegate.projectData RequestProjectData:CL_KEY];
		[AppDelegate.folderData clear];
		[AppDelegate->theNewBookingControlller.ProjectButton setEnabled:YES];
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Picked client not found in database. That is bug." message:pickedClient delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
	[self checkIfBookingIsReady];
}

-(void)UserPickedProject:(NSNotification *)notification
{
	
	NSNumber *pickedProjectID = (NSNumber *) [notification object];
	
	PR_KEY = [pickedProjectID intValue];
	
	DLog(@"Yeps, %d picked", PR_KEY);
	
	// Find ProjectName
	NSString *projectName=@"";
	for(int i=0;i<[AppDelegate.projectData Count];i++)
		{
		ProjectInfo *C = [AppDelegate.projectData GetProjectByIndex:i];
		if(PR_KEY == C->PR_KEY)
			{
			projectName = C->PR_NAME;
			break;
			}
		}
	if([projectName compare:@""] != NSOrderedSame)
		{
		[AppDelegate.folderData RequestFolderData:PR_KEY];
		[AppDelegate->theNewBookingControlller.FolderButton setEnabled:YES];
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Picked project not found in database. That is bug." message:projectName delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}

	[ProjectButton setTitle:projectName forState:UIControlStateNormal];
	[AppDelegate.folderData clear];
	[FolderButton setTitle:@"Select folder" forState:UIControlStateNormal];

	[self checkIfBookingIsReady];
}

-(void)UserPickedFolder:(NSNotification *)notification
{
	NSNumber *pickedFolderID = (NSNumber *) [notification object];
	
	WO_KEY = [pickedFolderID intValue];
	
	DLog(@"Yeps, %d picked", WO_KEY);
	
	NSString *folderName=@"";
	for(int i=0;i<[AppDelegate.folderData Count];i++)
		{
		FolderInfo *C = [AppDelegate.folderData GetFolderByIndex:i];
		if(WO_KEY == C->WO_KEY)
			{
			folderName = C->NAME;
			break;
			}
		}
	if([folderName compare:@""] != NSOrderedSame)
		{

		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Picked folder not found in database. That is bug." message:folderName delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
	
	[FolderButton setTitle:folderName forState:UIControlStateNormal];


	[self checkIfBookingIsReady];
}

-(IBAction) CancelBooking:(id)sender
{
	[BookedResources removeAllObjects];
	GanttView *asd = self.gantt;
	[asd removeFromSuperview];
	asd.frame = CGRectMake(0,0,1024, 724);
	[AppDelegate->ganttviewcontroller.view addSubview:asd];
	[asd setNeedsDisplay];
	[self dismissModalViewControllerAnimated:NO];
	AppDelegate->ganttviewcontroller.isCreatingNewBooking = NO;

	CL_KEY=0;
	PR_KEY=0;
	WO_KEY=0;
	[ProjectButton setTitle:@"Select Project" forState:UIControlStateNormal];
	[ClientButton setTitle:@"Select Client" forState:UIControlStateNormal];
	[FolderButton setTitle:@"Select Folder" forState:UIControlStateNormal];

	[AppDelegate.ganttviewcontroller.gantt.invisibleScrollView setUserInteractionEnabled:YES];
}



-(void) checkIfBookingIsReady
{
	if(CL_KEY != 0 && PR_KEY != 0 && WO_KEY != 0)
		[confirmBookingButton setEnabled:YES];
}

-(IBAction) ConfirmBooking:(id)sender
{
	// Let's make the booking for real

	/*
	EXEC  [dbo].[BOOKING_CREATE]
	@CL_KEY = 9130,
	@PR_KEY = 311704,
	@WO_KEY = 85291,
	@AC_KEY = 78,
	@FROM_TIME = N'2011-09-26 09:00',
	@TO_TIME = N'2011-09-26 19:00',
	@SITE_KEY = 9999,
	@KeyList = N'101,109'  -- RE_KEYS for booking slots
	*/

	if(CL_KEY == 0)
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please select a Client, Project and Folder." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release]; 
		return;
		}
	
	if(PR_KEY == 0)
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please select a Project and Folder." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release]; 
		return;
		}
	
	if(WO_KEY == 0)
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please select a Folder." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release]; 
		return;
		}
	

	[self CreateBookingInDataBase];
	
	GanttView *asd = self.gantt;
	[asd removeFromSuperview];
	asd.frame = CGRectMake(0,0,1024, 724);
	[AppDelegate->ganttviewcontroller.view addSubview:asd];
	[asd setNeedsDisplay];
	[self dismissModalViewControllerAnimated:NO];
	AppDelegate->ganttviewcontroller.isCreatingNewBooking = NO;
	[AppDelegate.ganttviewcontroller.gantt.invisibleScrollView setUserInteractionEnabled:YES];
}

/* Uncomment to make test booking
-(void) viewWillAppear:(BOOL)animated
{
 [super viewWillAppear];
 // Make test booking
	ResourceAndTime C;
	C.RE_KEY = AppDelegate.loginData.Login.RE_KEY;
	
	// Find resource name
    for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)// for all resources
		{
		if(AppDelegate->viewData.Resources[i].RE_KEY == C.RE_KEY)
			{
			C.RE_NAME = AppDelegate->viewData.Resources[i].RE_NAME;
			break;
			}
		}
	NSDate *a=[NSDate date];
	Date today(a);
	C.FROM_TIME=today.HoursBefore(2);
	C.TO_TIME=today.HoursAfter(6);
	
	BookedResources.push_back(C);
	[self.tableView reloadData];
}
*/


- (void)CreateBookingInDataBase
{
	if([BookedResources count] == 0)
		return;
	
	Date FROM_TIME = ((ResourceAndTime*)[BookedResources objectAtIndex:0]).FROM_TIME;
	Date TO_TIME = ((ResourceAndTime*)[BookedResources objectAtIndex:0]).TO_TIME;
	for(int i=0;i<[BookedResources count];i++)
		{
		if(((ResourceAndTime*)[BookedResources objectAtIndex:i]).FROM_TIME.nstimeInterval() < FROM_TIME.nstimeInterval())
			FROM_TIME = ((ResourceAndTime*)[BookedResources objectAtIndex:i]).FROM_TIME;
		if(((ResourceAndTime*)[BookedResources objectAtIndex:i]).TO_TIME.nstimeInterval() > TO_TIME.nstimeInterval())
			TO_TIME = ((ResourceAndTime*)[BookedResources objectAtIndex:i]).TO_TIME;
		}

	BO_KEY=0;	// booking not created yet
	
	NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_BOOKING_CREATE @CL_KEY=%d, @PR_KEY=%d, @WO_KEY=%d, @AC_KEY=%d, @FROM_TIME='%@', @TO_TIME='%@', @SITE_KEY=%d", CL_KEY, 
						 PR_KEY, WO_KEY, AC_KEY, FROM_TIME.FormatForSQLWithTime(), TO_TIME.FormatForSQLWithTime(), AppDelegate->loginData.Login.SITE_KEY];

	DLog("Creating booking: %@", request);
	[AppDelegate.client executeQuery:request withDelegate:self];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	cout << "Got Project Data, Processing" << endl;
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
			NSInteger BO_KEY_INDEX = [resultSet indexForField:@"BO_KEY"];
			while ([resultSet moveNext])
				{
				if(BO_KEY == 0)
					{
					BO_KEY = [ resultSet getInteger: BO_KEY_INDEX ];
					
					// Add the booking comment
					
					NSMutableString *text = [FolderRemarksTextView.text mutableCopy];
					
					NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_UPDATE_BK_REMARK %d, '%@ %@', '%@';", BO_KEY, AppDelegate->loginData.Login.FULL_NAME, @"iPad", text];
					DLog(@"%@", request);
					[AppDelegate.client executeQuery:request withDelegate:self];
					[text release];
					
					// Add booking slots
					for(int i=0;i<[BookedResources count];i++)
						{
						NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_BOOKING_SLOT_CREATE @BO_KEY=%d, @RE_KEY=%d, @FROM_TIME='%@', @TO_TIME='%@', @SITE_KEY=%d", BO_KEY, ((ResourceAndTime*)[BookedResources objectAtIndex:i]).RE_KEY,
										 ((ResourceAndTime*)[BookedResources objectAtIndex:i]).FROM_TIME.FormatForSQLWithTime(),
										 ((ResourceAndTime*)[BookedResources objectAtIndex:i]).TO_TIME.FormatForSQLWithTime(),AppDelegate->loginData.Login.SITE_KEY];
						DLog("Adding booking slot : %@ for resource %d (%d)", request, ((ResourceAndTime*)[BookedResources objectAtIndex:i]).RE_KEY, i);
						[AppDelegate.client executeQuery:request withDelegate:self];
						}
					}
			else
				{
				NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
				for (SqlResultSet *resultSet in query.resultSets)
					{
					for (int i = 0; i < resultSet.fieldCount; i++)
						{
						[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
						}
					DLog(@"%@", outputString);
					}
				}
			}// While move next
			}// for resultSet in query.resultSets
		}// if succeeded
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error creating booking" message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
	[AppDelegate->ganttviewcontroller RefreshBookings];
}

/*
- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
	cout << "Got Folder Data, Processing" << endl;
	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
			if(1)
				{
				NSInteger BO_KEY_INDEX = [resultSet indexForField:@"BO_KEY"];
				NSObject *VALUE = [ resultSet getObject:0];
				DLog(@"%@", VALUE);
//				BO_KEY = [VALUE intValue];
			
				// Add booking slots
				for(int i=0;i<BookedResources.size();i++)
					{
					NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_BOOKING_SLOT_CREATE @BO_KEY=%d, @RE_KEY=%d, @FROM_TIME='%@', @TO_TIME='%@', @SITE_KEY=%d", BO_KEY, BookedResources[i].RE_KEY,
										 BookedResources[i].FROM_TIME.FormatForSQLWithTime(),
										 BookedResources[i].TO_TIME.FormatForSQLWithTime(),AppDelegate->loginData.Login.SITE_KEY];
					[AppDelegate.client executeQuery:request withDelegate:self];
					}
				}
			else
				{
				NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
					for (SqlResultSet *resultSet in query.resultSets)
						{
						for (int i = 0; i < resultSet.fieldCount; i++)
							{
							[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
							}
						DLog(@"%@", outputString);
						}
				}
			
			
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error creating booking" message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
}
						
			
			NSInteger WO_KEY = [resultSet indexForField:@"WO_KEY"];
			NSInteger NAME = [resultSet indexForField:@"NAME"];
 #ifdef ALLOW_NO_PROJECT_AND_FOLDER

			FolderInfo C;
			
			C.WO_KEY = -100;
			C.NAME = @"No folder selected";
			folders.push_back(C);
#endif			
			while ([resultSet moveNext])
				{
				C.WO_KEY = [ resultSet getInteger: WO_KEY ];
				if(C.WO_KEY <= 0)
					continue;
				
				NSString *FOLDERNAME = [resultSet getString: NAME];
				if(FOLDERNAME != nil && ([FOLDERNAME isKindOfClass:[NSString class]] == YES))
					C.NAME = [FOLDERNAME retain];
				else
					continue;
				folders.push_back(C);
				}
			
			}
		}
	else
		{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error executing query Folders" message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];   
		}
}

*/

@end
