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

@interface LoginDataContainer : NSObject
{
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

@property (nonatomic, retain) NSString *PASSWRD;
@property (nonatomic, retain) NSString *USERNAME;
@property (nonatomic, retain) NSString *FULL_NAME;
@property (nonatomic, retain) NSString *GROUP_NAME;
@property (nonatomic, retain) NSString *SITE_NAME;
@property (nonatomic, retain) NSString *LEGAL_ENTIRY;
@property (nonatomic, retain) NSString *SECTION;
@property (nonatomic, retain) NSString *DESCRIPTION1;
@property int ACCESS_RIGHTS;	// Bool
@property int SITE_KEY;		// Shortcut, use when requesting booking and resource data, "AND SITE_KEY=%d"
@property int USER_KEY;		// Whoami
@property int STAFF_CL_KEY;   // index into client database
@property int RE_KEY;			// 1543

-(void) clear;


@end

@interface LoginData : NSObject <SqlClientDelegate, UIAlertViewDelegate>
{
	NSString* loginName;
	NSString* password;
	LoginDataContainer *Login;
}

//@property (nonatomic, retain) IBOutlet GanttView *gantt;
@property (nonatomic, retain) NSString* loginName;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) LoginDataContainer *Login;


-(IBAction) RequestLoginData;
-(IBAction) Clear;
@end

