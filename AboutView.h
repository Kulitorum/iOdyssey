//
//  AboutView.h
//  iOdyssey
//
//  Created by Kulitorum on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutView : UIView
{
	NSTimer* timer;
	int ypos;
}
-(void) clockTick;

@end
