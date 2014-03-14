//
//  DateCell.h
//  iOdyssey
//
//  Created by Michael Holm on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Date.h"

@interface DateCell : UITableViewCell {
	IBOutlet UILabel *Title;
	IBOutlet UILabel *dateLabel;
}

@property (nonatomic) IBOutlet UILabel *Title;
@property (nonatomic) IBOutlet UILabel *dateLabel;

@end
