//
//  ConsumableCell.m
//  iOdyssey
//
//  Created by Michael Holm on 06/09/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

#import "ConsumableCell.h"

@implementation ConsumableCell


@synthesize amount, unit, name, whereToPutTheNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)editingEnded:(id)sender
{
	*whereToPutTheNumber = [amount.text intValue];

	//    [sender resignFirstResponder]; 
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
    return NO;
}

@end
