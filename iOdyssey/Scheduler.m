//
//  Scheduler.m
//  iOdyssey
//
//  Created by Kulitorum on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scheduler.h"

@implementation Scheduler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(bool) IsConnectedToWIFI
{
	return [UIDevice activeWLAN];
}

-(bool) IsOnline
{
	return [UIDevice networkAvailable];
}

@end
