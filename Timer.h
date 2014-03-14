//
//  Timer.h
//  iOdyssey
//
//  Created by Michael Holm on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <mach/mach_time.h>

class TimeController{
public:
	TimeController(){mach_timebase_info(&timeBaseInfo);}
	mach_timebase_info_data_t timeBaseInfo;
};

extern TimeController timeControllerInstance;

class Timer{
public:
	Timer()	{ startTime = mach_absolute_time();	}
	uint64_t RunTime()
	{
	return (( mach_absolute_time() - startTime) * timeControllerInstance.timeBaseInfo.numer / timeControllerInstance.timeBaseInfo.denom) / 1000000;	
	}
	
private:
	uint64_t startTime ;
};
