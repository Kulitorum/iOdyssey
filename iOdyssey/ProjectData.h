//
//  ProjectData.h
//  iOdyssey
//
//  Created by Kulitorum on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SqlClient.h"
#include <vector>
#include "Booking.h"

using namespace std;

class ProjectInfo
{
public:
	int PR_KEY;
	NSString *PR_NAME;
};

@interface ProjectData : UITableViewController <SqlClientDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
{
@public
	vector<ProjectInfo> projects;
	UITableView *tableView;
}


@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)RequestProjectData:(int)CL_KEY;

-(ProjectInfo*)GetProject:(int)CL_ID;
-(ProjectInfo*)GetProjectByIndex:(int)index;
-(int)Count;

@end
