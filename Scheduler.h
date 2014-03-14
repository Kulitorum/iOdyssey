//
//  Scheduler.h
//  iOdyssey
//
//  Created by Kulitorum on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDevice-Reachability.h"

@interface Scheduler : NSObject


-(bool) IsConnectedToWIFI;
-(bool) IsOnline;

@end
