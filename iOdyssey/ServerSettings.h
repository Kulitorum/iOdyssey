//
//  ServerSettings.h
//  iOdyssey
//
//  Created by Michael Holm on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextInputCell.h"

@interface ServerSettings : UIViewController  <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *table;
	TextInputCell *ServerCell;
	TextInputCell *DatabaseCell;
	TextInputCell *UsernameCell;
	TextInputCell *PasswordCell;
}

@property (nonatomic, retain) IBOutlet UITableView *table;

-(IBAction) Return:(id)sender;

@end
