/*
 DateViewController.m
 */
#import "DateViewController.h"
//#import "BirthdaysCategories.h"

@implementation DateViewController
@synthesize datePicker;
@synthesize date;
@synthesize delegate;

-(IBAction)dateChanged
{
    self.date = [datePicker date];
}
-(IBAction)cancel
{
    [[self.delegate navController] popViewControllerAnimated:YES];
}
-(IBAction)save
{
    [self.delegate takeNewDate:date];
    [[self.delegate navController] popViewControllerAnimated:YES];
}
- (void)loadView
{
    UIView *theView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = theView;
    [theView release];
    
	
    UIDatePicker *theDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 206.0, 320.0, 216.0)];
    self.datePicker = theDatePicker;
    [theDatePicker release];
    [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.date != nil)
        [self.datePicker setDate:date animated:YES];
    else 
        [self.datePicker setDate:[NSDate date] animated:YES];
    
    [super viewWillAppear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [datePicker release];
    [date release];
    [super dealloc];
}
@end
