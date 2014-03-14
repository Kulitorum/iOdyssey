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
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic) IBOutlet MyBookingsController *myBookingsController;

@end
