//
//  Consumables.h
//  iOdyssey
//
//  Created by Kulitorum on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlClient.h"
#include <vector>

using namespace std;

@interface Consumable : NSObject
{
@public
	int SC_KEY;
	NSString *SC_NAME;
	NSString *UNIT;
	int SCG_KEY;
	int QTY;
	int newQTY;
};

@property (nonatomic, retain) NSString *SC_NAME;
@property (nonatomic, retain) NSString *UNIT;


@end

@interface SCG : NSObject
{
@public
	int SCG_KEY;
	NSString *SCG_NAME;
	NSMutableArray *items;
};

@property (nonatomic, retain) NSString *SCG_NAME;

@end


@interface Consumables :  NSObject<SqlClientDelegate>
{
@public
	NSMutableArray *ServiceGroups;
	//	vector<Consumable> items;
	bool Ready;
}

@property bool Ready;
@property (copy) NSMutableArray *items;

- (void)RequestConsumableData:(int)BO_KEY;

@end
