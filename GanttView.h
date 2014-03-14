//
//  GanttView.h
//  iSqlExample
//
//  Created by Michael Holm on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SqlClient.h"
#import "ganttScrollView.h"

@interface GanttView : UIView<SqlClientDelegate>
{
	bool DoneUpdating;
	float RESOURCENAMEWIDTH;
	bool needsInit;
	GanttScrollView *invisibleScrollView;
}

@property (nonatomic) UIScrollView *invisibleScrollView;

-(IBAction) RequestResourceData;
-(IBAction) Redraw;

-(void) DrawDateGrid:(CGRect) rect withy:(float)y withColorSpace:(CGColorSpaceRef)colorSpace WithContext:(CGContextRef) context;

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);
void drawGradientWithGloss(CGContextRef context, CGRect rect, CGColorRef startColor,  CGColorRef endColor);


@property bool needsInit;
@property bool DoneUpdating;
@property float RESOURCENAMEWIDTH;
@end
