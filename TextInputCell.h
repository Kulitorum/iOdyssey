//
//  TextInputCell.h
//  iOdyssey
//
//  Created by Michael Holm on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextInputCell : UITableViewCell {
	IBOutlet UITextField *value;
	IBOutlet UILabel *Label;
}
@property (nonatomic) IBOutlet UITextField *value;
@property (nonatomic) IBOutlet UILabel *Label;

@end
