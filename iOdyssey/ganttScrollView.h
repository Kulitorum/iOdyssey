//
//  ganttScrollView.h
//  iOdyssey
//
//  Created by Michael Holm on 12/10/11.
//  Copyright (c) 2011 Kulitorum. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
@class GanttScrollView;
@protocol GanttScrollViewDelegate <NSObject>
@optional
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end
*/
@interface GanttScrollView : UIScrollView
{
	UIResponder *localDelegate;
	id UIScrollViewPagingSwipeGestureRecognizer;
}

//@property (nonatomic, assign) id <GanttScrollViewDelegate> delegate;

@end
