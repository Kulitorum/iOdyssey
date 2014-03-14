//
//  DateCell.m
//  iOdyssey
//
//  Created by Michael Holm on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DateCell.h"
#import "iOdysseyAppDelegate.h"


@implementation DateCell
@synthesize Title, dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


@end
