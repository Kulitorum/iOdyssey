//
//  bookingDetailController.m
//  iOdyssey
//
//  Created by Michael Holm on 6/30/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "BookingDetailController.h"

#import "DateCell.h"

#import "iOdysseyAppDelegate.h"

#include <vector>

using namespace std;

@implementation BookingDetailController

@synthesize table, book;
@synthesize signOffButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction) Return:(id)sender
{
	AppDelegate.lastViewedBookingKey = book->BS_KEY;
	[AppDelegate.myBookingsController RefreshView];
	
	if(self.navigationController == nil)                     // if we are in a modal view
		{
			// if we are in portrait mode, don't animate
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		
		if(orientation == UIDeviceOrientationPortrait || orientation==UIDeviceOrientationPortraitUpsideDown)
			{
			[self dismissModalViewControllerAnimated :NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self];
			}
		else
			[self dismissModalViewControllerAnimated :YES];

		}
	else
		[self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc
{
    [super dealloc];
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
		// If called from the gantt view, remove the add comment button
	
	if(book -> MTYPE == 1)// hide signoff button
		{
		NSLog(@"Show sign off button");
		[signOffButton setEnabled:TRUE];
		}
	else
		{
		NSLog(@"Hide sign off button");
		[signOffButton setEnabled:FALSE];
		}
	
    [table scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}


-(void)viewDidAppear:(BOOL)animated
{
	cout << " Booking Detail controller :: viewDidAppear" << endl;
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;//(UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

void FindResourcesForBookingID( int BO_KEY, std::vector<Booking*> &result)
{
    //	cout << "FindResourcesForBookingID ID " << BO_KEY << endl;
    
	for(size_t i=0;i<AppDelegate->viewData.Resources.size();i++)
		for(size_t b=0;b<AppDelegate->viewData.Resources[i].bookings.size();b++)
			if(AppDelegate->viewData.Resources[i].bookings[b].BO_KEY == BO_KEY)
				result.push_back(&AppDelegate->viewData.Resources[i].bookings[b]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	vector<Booking*> bookings;
	FindResourcesForBookingID(book->BO_KEY, bookings);
    if(indexPath.section < bookings.size())
        return 33;	// start, end

	
	/*
	 enum CStatus{ROS, BKS, BK, A16, A35, HL1, HL2, IO, CNI, CND, P01, NA, MET, TRA, SIP, GRATIS, INVOICED, UNKNOWN, ERROR};
	 
	 enum PCODE{P_UNKNOWN, P_OPEN, P_FINISHED, P_APPROVED, P_PRECALC, P_PROFORMA, P_INVOICED, P_LOGGEDOUT, P_ERROR};
	 */
	NSString* status;
	switch(book->STATUS)
	{
		case ROS: status=@"ROS"; break;
		case BKS: status=@"BKS"; break;
		case BK: status=@"BK"; break;
		case A16: status=@"A16"; break;
		case A35: status=@"A35"; break;
		case HL1: status=@"HL1"; break;
		case HL2: status=@"HL2"; break;
		case IO: status=@"IO"; break;
		case CNI: status=@"CNI"; break;
		case CND: status=@"CND"; break;
		case P01: status=@"P01"; break;
		case NA: status=@"NA"; break;
		case MET: status=@"MET"; break;
		case TRA: status=@"TRA"; break;
		case SIP: status=@"SIP"; break;
		case GRATIS: status=@"GRATIS"; break;
		case INVOICED: status=@"INVOICED"; break;
		case UNKNOWN: status=@"UNKNOWN"; break;
		case ERROR: status=@"ERROR"; break;
	}
	NSString* pcode;
	switch(book->pcode)
	{
		case P_UNKNOWN: pcode=@"UNKNOWN"; break;
		case P_OPEN: pcode=@"OPEN"; break;
		case P_FINISHED: pcode=@"FINISHED"; break;
		case P_APPROVED: pcode=@"APPROVED"; break;
		case P_PRECALC: pcode=@"PRECALC"; break;
		case P_PROFORMA: pcode=@"PROFORMA"; break;
		case P_INVOICED: pcode=@"INVOICED"; break;
		case P_LOGGEDOUT: pcode=@"LOGGEDOUT"; break;
		case P_GRATIS: pcode=@"GRATIS"; break;
		default:
		case P_ERROR: pcode=@"ERROR"; break;
	}
	
	
	
	NSString *cellText= [NSString stringWithFormat:
						 @"Client:		%@\nProject:		%@\nFolder:		%@\nStatus:		%@/%@\nActivity:		%@\n					%d/%@\
                                 \n=====================================\n                           Booking Remark\n=====================================\n%@\
                                 \n=====================================\n                             Folder Remark\n=====================================\n%@",
                                 book->CL_NAME, book->NAME, book->Folder_name, pcode, status, book->ACTIVITY, book->BO_KEY, book->NAME, book->BK_Remark, book->Folder_remark ];

    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:12.0];
	CGSize constraintSize;
	if(AppDelegate.IsIpad)
		constraintSize = CGSizeMake(1000.0f, MAXFLOAT);
    else
		constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 20;

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
	vector<Booking*> bookings;
	FindResourcesForBookingID(book->BO_KEY, bookings);
    if(section < bookings.size())
        return 2;	// start, end
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	vector<Booking*> bookings;
	FindResourcesForBookingID(book->BO_KEY, bookings);
	
	return bookings.size()+1;	// number of resources booked + comments
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	vector<Booking*> bookings;
	FindResourcesForBookingID(book->BO_KEY, bookings);
	
	if(section < bookings.size())// compiled name of resource if we are displaying a resource
	   {
	   if([bookings[section]->TYPE compare:@"S"] == NSOrderedSame)
		   return [[bookings[section]->FIRST_NAME stringByAppendingString:@" "] stringByAppendingString:bookings[section]->LAST_NAME];
	   return bookings[section]->Resource;
	   }
   return @"Booking Info";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	vector<Booking*> bookings;
	FindResourcesForBookingID(book->BO_KEY, bookings);
	
//	cout << "Cell:" << indexPath.section << ", " << indexPath.row << " of " << bookings.size() << "Bookings" << endl;
	
	if(indexPath.section < bookings.size() )
		{
		DateCell *cell = (DateCell *)[table dequeueReusableCellWithIdentifier:@"DateCell_ID"];
		if (cell == nil)
			{
			DLog(@"New DateCell Made");
			
			NSString *nibName;
/*			if(AppDelegate.IsIpad)
				nibName = @"DateCell_ipad";
			else*/
				nibName = @"DateCell_iphone";
			
			NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];		
			for(id currentObject in topLevelObjects)
				{
				if([currentObject isKindOfClass:[DateCell class]])
					{
					cell = (DateCell *)currentObject;
					break;
					}
				}
			}
		
		switch(indexPath.row)
			{
				case 0:	// DateCell start
				[[cell Title] setText:@"Start"];
				[[cell dateLabel] setText: bookings[indexPath.section]->FROM_TIME.FormatForSignOffController() ];
				break;
				case 1:	// DateCell start
				[[cell Title] setText:@"End"];
				[[cell dateLabel] setText: bookings[indexPath.section]->TO_TIME.FormatForSignOffController() ];
				break;
			}
		return cell;
		}
	
    UITableViewCell *commentcell = [tableView dequeueReusableCellWithIdentifier:@"COMMENTCELL"];
    if (commentcell == nil) {
        commentcell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"COMMENTCELL"] autorelease];
    }
	NSString* status;
	switch(book->STATUS)
	{
		case ROS: status=@"ROS"; break;
		case BKS: status=@"BKS"; break;
		case BK: status=@"BK"; break;
		case A16: status=@"A16"; break;
		case A35: status=@"A35"; break;
		case HL1: status=@"HL1"; break;
		case HL2: status=@"HL2"; break;
		case IO: status=@"IO"; break;
		case CNI: status=@"CNI"; break;
		case CND: status=@"CND"; break;
		case P01: status=@"P01"; break;
		case NA: status=@"NA"; break;
		case MET: status=@"MET"; break;
		case TRA: status=@"TRA"; break;
		case SIP: status=@"SIP"; break;
		case GRATIS: status=@"GRATIS"; break;
		case INVOICED: status=@"INVOICED"; break;
		case UNKNOWN: status=@"UNKNOWN"; break;
		case ERROR: status=@"ERROR"; break;
	}
	NSString* pcode;
	switch(book->pcode)
	{
		case P_UNKNOWN: pcode=@"UNKNOWN"; break;
		case P_OPEN: pcode=@"OPEN"; break;
		case P_FINISHED: pcode=@"FINISHED"; break;
		case P_APPROVED: pcode=@"APPROVED"; break;
		case P_PRECALC: pcode=@"PRECALC"; break;
		case P_PROFORMA: pcode=@"PROFORMA"; break;
		case P_INVOICED: pcode=@"INVOICED"; break;
		case P_LOGGEDOUT: pcode=@"LOGGEDOUT"; break;
		case P_GRATIS: pcode=@"GRATIS"; break;
		default:
		case P_ERROR: pcode=@"ERROR"; break;
	}
    
    // Configure the cell...
	commentcell.textLabel.text= [NSString stringWithFormat:
						 @"Client:		%@\nProject:		%@\nFolder:		%@\nStatus:		%@/%@\nActivity:		%@\n					%d/%@\
						 \n=====================================\n                           Booking Remark\n=====================================\n%@\
						 \n=====================================\n                             Folder Remark\n=====================================\n%@",
						 book->CL_NAME, book->NAME, book->Folder_name, pcode, status, book->ACTIVITY, book->BO_KEY, book->NAME, book->BK_Remark, book->Folder_remark ];
    commentcell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    commentcell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    commentcell.textLabel.numberOfLines = 0;
    commentcell.selectionStyle = UITableViewCellSelectionStyleNone;
    [commentcell.textLabel sizeToFit];
    
    return commentcell;

}

-(IBAction) AddComment
{
	AppDelegate->addCommentViewController.book = self.book;
	[self.navigationController pushViewController:AppDelegate->addCommentViewController animated:YES];
}

-(IBAction) ShowSignOffViewController
{
	AppDelegate->signOffViewController.book = self.book;
	[self.navigationController pushViewController:AppDelegate->signOffViewController animated:YES];
}


@end



























