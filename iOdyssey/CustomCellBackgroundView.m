//
//  CustomCellBackgroundView.m
//
//  Created by Mike Akers on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CustomCellBackgroundView.h"
#import "iOdysseyAppDelegate.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect,
								 float ovalWidth,float ovalHeight);

@implementation CustomCellBackgroundView
@synthesize borderColor, fillColor, passedBookingsColor, progressColor, openPassedBookingsColor, position, progress, book;

- (BOOL) isOpaque {
    return NO;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		book=nil;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	float r=10.0f;
	
    CGContextRef c = UIGraphicsGetCurrentContext();
	
	if(progress >= 1)
		if(book && book->pcode == P_OPEN && book->MTYPE==1)
			CGContextSetFillColorWithColor(c, [openPassedBookingsColor CGColor]);
		else
			CGContextSetFillColorWithColor(c, [passedBookingsColor CGColor]);
	else
		CGContextSetFillColorWithColor(c, [fillColor CGColor]);
	
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);

    if (position == CustomCellBackgroundViewPositionTop)
		{
        CGContextFillRect(c, CGRectMake(0.0f, rect.size.height - r, rect.size.width, r)); // Bottom part rect
		// finish the BG
		CGContextBeginPath(c);
		addRoundedRectToPath(c, rect, r, r);
		CGContextFillPath(c);	// white fill
		if(progress > 0 && progress < 1)
			{
			float progressInPixels = rect.size.width*progress;
			CGContextSaveGState(c);
			CGContextClipToRect(c, CGRectMake(0.0f, 0.0f, progressInPixels, rect.size.height));
			CGContextBeginPath(c);
			addRoundedRectToPath(c, rect, r, r);
			CGContextSetFillColorWithColor(c, [progressColor CGColor]);
			CGContextFillPath(c);
			CGContextFillRect(c, CGRectMake(0.0f, r, rect.size.width, rect.size.height));
			CGContextRestoreGState(c);
			}
		CGContextBeginPath(c);
        CGContextMoveToPoint(c, 0.0f, rect.size.height - r);
        CGContextAddLineToPoint(c, 0.0f, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height - r);
        CGContextStrokePath(c);
        CGContextClipToRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height-r));
		}
	else if (position == CustomCellBackgroundViewPositionBottom)
		{
        CGContextFillRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, r));
		// finish BG
		CGContextBeginPath(c);
		addRoundedRectToPath(c, rect, r, r);
		CGContextFillPath(c);	// white fill
		if(progress > 0 && progress < 1)
			{
			float progressInPixels = rect.size.width*progress;
			CGContextSaveGState(c);
			CGContextClipToRect(c, CGRectMake(0.0f, 0.0f, progressInPixels, rect.size.height));
			CGContextBeginPath(c);
			addRoundedRectToPath(c, rect, r, r);
			CGContextSetFillColorWithColor(c, [progressColor CGColor]);
			CGContextFillPath(c);
			CGContextFillRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height-r));
			CGContextRestoreGState(c);
			}

        CGContextBeginPath(c);
        CGContextMoveToPoint(c, 0.0f, r);
        CGContextAddLineToPoint(c, 0.0f, 0.0f);
        CGContextStrokePath(c);
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, rect.size.width, 0.0f);
        CGContextAddLineToPoint(c, rect.size.width, r);
        CGContextStrokePath(c);
        CGContextClipToRect(c, CGRectMake(0.0f, r, rect.size.width, rect.size.height));
		}
	else if (position == CustomCellBackgroundViewPositionMiddle)
		{
        CGContextFillRect(c, rect);
		if(progress > 0 && progress < 1)
			{
			CGContextSaveGState(c);
			float progressInPixels = rect.size.width*progress;
			CGContextSetFillColorWithColor(c, [progressColor CGColor]);
			CGContextFillRect(c, CGRectMake(0.0f, 0.0f, progressInPixels, rect.size.height));
			CGContextRestoreGState(c);
			}

		CGContextBeginPath(c);
        CGContextMoveToPoint(c, 0.0f, 0.0f);
        CGContextAddLineToPoint(c, 0.0f, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, 0.0f);
        CGContextStrokePath(c);
        return; // no need to bother drawing rounded corners, so we return
		}
	else if (position == CustomCellBackgroundViewPositionSingle)
		{
		CGContextBeginPath(c);
		addRoundedRectToPath(c, rect, r, r);  
		CGContextFillPath(c);     
		}
	
    CGContextBeginPath(c);
    addRoundedRectToPath(c, rect, r, r);
	if(	AppDelegate.lastViewedBookingKey == book->BS_KEY)
		{
		[[UIColor colorWithRed:1 green:0.3 blue:0 alpha:1.0] setStroke];
		CGContextSetLineWidth(c, 3.0);
		}
	CGContextStrokePath(c);     
}


- (void)dealloc {
    [borderColor release];
    [fillColor release];
	[progressColor release];
	[passedBookingsColor release];
	[openPassedBookingsColor release];
    [super dealloc];
}


@end

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight)

{
    float fw, fh;
	
    if (ovalWidth == 0 || ovalHeight == 0) {// 1
        CGContextAddRect(context, rect);
        return;
    }
	
    CGContextSaveGState(context);// 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
						   CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
	
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    CGContextClosePath(context);// 12
	
    CGContextRestoreGState(context);// 13
}























