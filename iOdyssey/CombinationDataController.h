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
#include <iostream>
#include <vector>

using namespace std;

class Combination{
public:
    Combination(int key, NSString *name){RV_KEY = key; RV_NAME = [name copy];}
    
    int RV_KEY;
    NSString *RV_NAME;
};

@interface CombinationDataController : NSObject<SqlClientDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    vector<Combination> views;
}
@property vector<Combination> views;
-(void) RequestCombinationData;
@end
