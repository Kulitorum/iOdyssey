
/*
     File: ViewController.m
 Abstract: View controller that adds a keyboard accessory to a text view.
 
  Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "AddCommentViewController.h"
#import "iOdysseyAppDelegate.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"

@implementation AddCommentViewController

@synthesize textView, accessoryView, book;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.textView = nil;
    self.accessoryView = nil;
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    
    // Make the keyboard appear when the application launches.
    [super viewWillAppear:animated];
    [textView becomeFirstResponder];
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
*/

#pragma mark -
#pragma mark Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
	textView.text = @"";	// clear edit field
	
    if (textView.inputAccessoryView == nil)
    {
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = accessoryView;
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
    }
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */

    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.textView.bounds;
	if(AppDelegate.IsIpad)
		newTextViewFrame.origin.y = 61;
	else
		newTextViewFrame.origin.y = 41;
    newTextViewFrame.size.height = keyboardTop - newTextViewFrame.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    textView.frame = newTextViewFrame;

    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    textView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}


#pragma mark -
#pragma mark Accessory view action

- (IBAction)Done:(id)sender
{
    // When the accessory view button is tapped, add a suitable string to the text view.
    NSMutableString *text = [textView.text mutableCopy];
	NSString *request = [NSString stringWithFormat:@"EXEC dbo.IOS_UPDATE_BK_REMARK %d, '%@ %@', '%@';", book.BO_KEY, book.FIRST_NAME,book.LAST_NAME, text];
	DLog(@"%@", request);
	[AppDelegate.client executeQuery:request withDelegate:self];
}

- (IBAction)Cancel:(id)sender
{
    textView.text = @"";
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query
{
    cout << "Got Commit Comment data, processing" << endl;
	NSMutableString *outputString = [NSMutableString stringWithCapacity:1024];
	if (query.succeeded)
		{
		for (SqlResultSet *resultSet in query.resultSets)
			{
			for (int i = 0; i < resultSet.fieldCount; i++)
				{
				[outputString appendFormat:@"%@ ", [resultSet nameForField:i]];
				}
			[outputString appendString:@"\r\n--------\r\n"];
			
			DLog(@"%@", outputString);
			}
		}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network connection lost. Please try again." message:query.errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
	[AppDelegate.ganttviewcontroller RefreshBookings];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

















@end
