/*
 DateViewController.h
 */

#import <UIKit/UIKit.h>
//#import "Person.h"

@protocol DateViewDelegate <NSObject>

@required
- (void)takeNewDate:(NSDate *)newDate;
- (UINavigationController *)navController;          // Return the navigation controller
@end

@interface DateViewController : UIViewController {
    UIDatePicker            *datePicker;
    NSDate                  *date;
    
    id <DateViewDelegate>   delegate;   // weak ref
}
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign)  id <DateViewDelegate> delegate;
-(IBAction)dateChanged;
@end
