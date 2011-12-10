//
//  ColorData.h
//  iOdyssey
//
//  Created by Kulitorum on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlClient.h"
#include <vector>
#include "Booking.h"

using namespace std;

class ColorInfo
{
public:
	int SSC_KEY;
	int SUB_KEY;
	NSString *SSC_NAME;
	NSString *ABBR;
	unsigned char COLOR_RED;
	unsigned char COLOR_GREEN;
	unsigned char COLOR_BLUE;
	int COLOR2;
	CStatus STATUS;
	CGColorRef COLOR;
};

//enum PCODE{P_UNKNOWN, P_OPEN, P_ACTUAL, P_PROFORMA, P_INVOICED, P_GRATIS};


class ColorInfoBookingState : public ColorInfo
{
public:
	//	id Name ABBR Color Remark
	int id;
	NSString *Name;
	int Color;
	PCODE pcode;
};

@interface ColorData : NSObject<SqlClientDelegate>
{
	vector<ColorInfo> colors;
	vector<ColorInfoBookingState> colors2;
	bool isGettingBOOKING_STATE;
}

@property bool isGettingBOOKING_STATE;

- (void)RequestColorData;
- (void)RequestColorData2;

-(ColorInfo*)GetColor:(CStatus) STATUS withPCODE:(PCODE)pcode;

@end
