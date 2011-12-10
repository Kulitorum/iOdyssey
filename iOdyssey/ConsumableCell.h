//
//  ConsumableCell.h
//  iOdyssey
//
//  Created by Michael Holm on 06/09/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumableCell : UITableViewCell <UITextFieldDelegate>
{
	IBOutlet UITextField *amount;
	IBOutlet UILabel *name;
	IBOutlet UILabel *unit;
	int *whereToPutTheNumber;
}

@property (nonatomic, retain) IBOutlet UITextField *amount;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *unit;
@property (nonatomic, assign) int *whereToPutTheNumber;

-(IBAction)editingEnded:(id)sender;

@end
