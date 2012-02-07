//
//  SettingsViewController.h
//  iOdyssey
//
//  Created by Michael Holm on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#pragma once
#import <UIKit/UIKit.h>
#import "SqlClient.h"

@interface Combination : NSObject
{
	int RV_KEY;
    NSString *RV_NAME;
}

@property int RV_KEY;
@property (nonatomic, retain) NSString *RV_NAME;

-(id)initWithData:(int)nr name:(NSString*) name;

@end

@interface CombinationDataController : NSObject<SqlClientDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
	NSMutableArray *views;
}
@property (nonatomic, retain) NSMutableArray *views;
-(void) RequestCombinationData;
@end
