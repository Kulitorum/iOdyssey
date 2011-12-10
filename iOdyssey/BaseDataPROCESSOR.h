//
//  LoginData.h
//  iOdyssey
//
//  Created by Michael Holm on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <vector>

#import "SqlClient.h"

using namespace std;

class LoginDataContainer
{
public:
	LoginDataContainer(){}
};


@interface LoginData : NSObject <SqlClientDelegate>
{
	vector<LoginDataContainer> Login;
}

//@property (nonatomic, retain) IBOutlet GanttView *gantt;
@property (nonatomic, retain) SqlClient *client;

-(IBAction) Refresh;
-(IBAction) Clear;
@end

