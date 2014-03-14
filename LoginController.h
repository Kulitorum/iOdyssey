//
//  LoginController.h
//  iOdyssey
//
//  Created by Michael Holm on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *table;
	bool HasBeenLoggedInOK;
	bool isPushed;
	bool isDisplayingModalVewController;
}

@property (nonatomic) IBOutlet UITableView *table;
@property bool HasBeenLoggedInOK;
@property bool isPushed;
@property bool isDisplayingModalVewController;

-(IBAction) DoLogin:(id)sender;
-(IBAction) LoginOK;
-(IBAction) LoginFailed;

@end
