//
//  LoginData.h
//  iOdyssey
//
//  Created by Michael Holm on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <vector>
#import <string>

#import "SqlClient.h"

using namespace std;

class LoginDataContainer
{
public:
	LoginDataContainer(){}
	
	void clear()
	{
	PASSWRD = USERNAME = FULL_NAME = GROUP_NAME = SITE_NAME = LEGAL_ENTIRY = SECTION = DESCRIPTION1 = @"";
	USER_KEY = STAFF_CL_KEY = RE_KEY = SITE_KEY = -1;
	}
	
	NSString *PASSWRD;
	NSString *USERNAME;
	NSString *FULL_NAME;
	NSString *GROUP_NAME;
	NSString *SITE_NAME;
	NSString *LEGAL_ENTIRY;
	NSString *SECTION;
	NSString *DESCRIPTION1;
	int ACCESS_RIGHTS;	// Bool
	int SITE_KEY;		// Shortcut, use when requesting booking and resource data, "AND SITE_KEY=%d"
	int USER_KEY;		// Whoami
	int STAFF_CL_KEY;   // index into client database
	int RE_KEY;			// 1543
};


@interface LoginData : NSObject <SqlClientDelegate, UIAlertViewDelegate>
{
	NSString* loginName;
	NSString* password;
	LoginDataContainer Login;
}

//@property (nonatomic, retain) IBOutlet GanttView *gantt;
@property (nonatomic, retain) NSString* loginName;
@property (nonatomic, retain) NSString* password;
@property LoginDataContainer Login;


-(IBAction) RequestLoginData;
-(IBAction) Clear;
@end

