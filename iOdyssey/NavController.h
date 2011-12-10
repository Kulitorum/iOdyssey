//
//  NavController.h
//  iOdyssey
//
//  Created by Michael Holm on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "MyBookingsController.h"

@interface NavController : UINavigationController {
  	UIActivityIndicatorView *activityIndicator;
	MyBookingsController *myBookingsController;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet MyBookingsController *myBookingsController;

@end
