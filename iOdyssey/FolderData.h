//
//  FolderData.h
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

class FolderInfo
{
public:
	int WO_KEY;
	NSString *NAME;
};

@interface FolderData : UITableViewController <SqlClientDelegate, UITableViewDataSource, UITableViewDelegate>
{
@public
	vector<FolderInfo> folders;
	UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)RequestFolderData:(int)PR_KEY;

-(FolderInfo*)GetFolder:(int)PR_KEY;
-(FolderInfo*)GetFolderByIndex:(int)index;
-(int)Count;
-(void)clear;

@end
