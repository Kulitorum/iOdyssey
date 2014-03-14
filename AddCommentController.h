//
//  AddCommentController.h
//  iOdyssey
//
//  Created by Kulitorum on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentController : UIViewController
{
	bool keyboardIsShown;
	IBOutlet UITextView *textView;
}

-(IBAction)DoneEditing;
-(IBAction)textFieldDoneEditing:(id)sender;
-(void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up;

@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
