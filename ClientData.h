//
//  ClientData.h
//  iOdyssey
//
//  Created by Michael Holm on 05/10/11.
//  Copyright 2011 Kulitorum. All rights reserved.
//

//select CL_KEY, CL_NAME FROM dbo.CLIENT WHERE ACCOUNT_CLOSED = 0 AND CL_ID > '' AND SITE_KEY = 9999 ORDER BY CL_NAME


#import <Foundation/Foundation.h>
#import "SqlClient.h"
#include <vector>
#include "Booking.h"

using namespace std;

@interface ClientInfo : NSObject
{
	int CL_KEY;
	NSString *CL_NAME;
};

@property int CL_KEY;
@property (nonatomic) NSString *CL_NAME;

@end

@interface ClientData : NSObject<SqlClientDelegate>
{
	NSMutableArray *clients;
}

- (void)RequestClientData;

-(ClientInfo*)GetClient:(int)CL_ID;
-(ClientInfo*)GetClientByIndex:(int)index;
-(int)Count;

@end
