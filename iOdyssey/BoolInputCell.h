//
//  BoolInputCell.h
//  iOdyssey
//
//  Created by Michael Holm on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BoolInputCell : UITableViewCell {
    IBOutlet UISwitch *value;
	IBOutlet UILabel *Label;

}
@property (nonatomic, retain) IBOutlet UISwitch *value;
@property (nonatomic, retain) IBOutlet UILabel *Label;

@end
