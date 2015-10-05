//
//  TipViewController.m
//  tipcalculator
//
//  Created by Matias Arenas Sepulveda on 9/21/15.
//  Copyright (c) 2015 Matias Arenas Sepulveda. All rights reserved.
//

#import "TipViewController.h"
#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TipViewController ()
@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UIView *resultsView;

- (IBAction)onTap:(id)sender;
- (IBAction)onBillEditingChanged:(id)sender;
- (void)updateValues;
- (void)showResultsView;
- (void)showInputOnlyView;
- (void)onSettingsButton;

@end

@implementation TipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    self = [super initWithNibName:<#nibNameOrNil#> bundle:<#nibBundleOrNil#>];
    if (self){
        self.title = @"Tip Calculator";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"min_tip_percentage"]) {
        [defaults setFloat:10.00 forKey:@"min_tip_percentage"];
        [defaults setFloat:15.00 forKey:@"mid_tip_percentage"];
        [defaults setFloat:20.00 forKey:@"max_tip_percentage"];
        [defaults synchronize];
    }

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.resultsView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:4.0f/255.0f green:171.0f/255.0f blue:208.0f/255.0f alpha:1.0f] CGColor], (id)[[UIColor colorWithRed:68.0f/255.0f green:119.0f/255.0f blue:194.0f/255.0f alpha:1.0f] CGColor], nil];
    [self.resultsView.layer insertSublayer:gradient atIndex:0];
    self.billTextField.layer.borderColor=[[UIColor colorWithRed:147.0f/255.0f green:213.0f/255.0f blue:226.0f/255.0f alpha:1.0f]CGColor];
    self.billTextField.layer.borderWidth=1.0f;
    self.billTextField.layer.cornerRadius = 5;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsButton)];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    [self updateValues];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
    NSLog(@"on tap");
    [self updateValues];
}

- (IBAction)onBillEditingChanged:(id)sender {
    NSLog(@"on bill editing changed");
    [self updateValues];
    [self updateViewWithAnimation:YES];
}

- (void)updateValues {
    float billAmount = [self.billTextField.text floatValue];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float min_percentage = [defaults floatForKey:@"min_tip_percentage"]/100.00;
    float mid_percentage = [defaults floatForKey:@"mid_tip_percentage"]/100.00;
    float max_percentage = [defaults floatForKey:@"max_tip_percentage"]/100.00;
    
    NSArray *tipValues = @[@(min_percentage), @(mid_percentage), @(max_percentage)];
    
    float tipAmount = billAmount * [tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    float totalAmount = tipAmount + billAmount;
    
    // Use the user's locale to format the currency and set the tip and total labels
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.tipLabel.text = [numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:tipAmount]];
    self.totalLabel.text = [numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:totalAmount]];
}

- (void)onSettingsButton {
    [self.navigationController pushViewController:[[SettingViewController alloc] init] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float min_percentage = [defaults floatForKey:@"min_tip_percentage"];
    float mid_percentage = [defaults floatForKey:@"mid_tip_percentage"];
    float max_percentage = [defaults floatForKey:@"max_tip_percentage"];
    [self.tipControl setTitle: [NSString stringWithFormat:@"%0.2f%%", min_percentage] forSegmentAtIndex:0];
    [self.tipControl setTitle: [NSString stringWithFormat:@"%0.2f%%", mid_percentage] forSegmentAtIndex:1];
    [self.tipControl setTitle: [NSString stringWithFormat:@"%0.2f%%", max_percentage] forSegmentAtIndex:2];
    
    // Update values since the tip percentage may have changed
    [self updateValues];
    
    // Put focus on the text field to make sure the keyboard shows
    [self.billTextField becomeFirstResponder];
    
    [super viewWillAppear:animated];
    
    NSLog(@"view will appear");
}

- (void)onApplicationDidBecomeActive {
    // Get the date at which the application last became inactive
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* lastTipDate = [defaults valueForKey:@"last_tip_date"];
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate:lastTipDate];
    
    //if less than 10 minutes the restore last value.
    if (interval < 600) {
        self.billTextField.text = [defaults valueForKey:@"last_bill_amount"];
        self.tipControl.selectedSegmentIndex = [defaults integerForKey:@"last_tip_segment_index"];
        float min_percentage = [defaults floatForKey:@"min_tip_percentage"];
        float mid_percentage = [defaults floatForKey:@"mid_tip_percentage"];
        float max_percentage = [defaults floatForKey:@"max_tip_percentage"];
        [self.tipControl setTitle: [NSString stringWithFormat:@"%0.2f%%", min_percentage] forSegmentAtIndex:0];
        [self.tipControl setTitle: [NSString stringWithFormat:@"%0.2f%%", mid_percentage] forSegmentAtIndex:1];
        [self.tipControl setTitle: [NSString stringWithFormat:@"%0.2f%%", max_percentage] forSegmentAtIndex:2];
        
    } else {
        self.billTextField.text = @"";
    }
    
    [self updateValues];
    
    // Update the view to either input-only or results, based on the newly set bill value.
    // Don't animate the view change, because it looks weird if you animate the view on first load.
    [self updateViewWithAnimation:NO];
}

- (void)dealloc
{
    // Remove the application life-cycle observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}

- (void)onApplicationWillResignActive {
    
    // Save the current bill amount, tip percentage, and the current time.
    // If the user comes back to the app before 10 minutes, we restore these values.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.billTextField.text forKey:@"last_bill_amount"];
    [defaults setObject:[NSDate date] forKey:@"last_tip_date"];
    [defaults setInteger:self.tipControl.selectedSegmentIndex forKey:@"last_tip_segment_index"];
    [defaults synchronize];
}

- (void)updateViewWithAnimation:(BOOL)animated {
    // Obtain the bill amount input by the user
    float billAmount = [self.billTextField.text floatValue];
    
    // If bill value is 0, show the input-only view.
    // If bill value > 0, show the results view.
    if (billAmount == 0) {
        [self showInputOnlyViewWithAnimation:animated];
    } else {
        [self showResultsViewWithAnimation:animated];
    }
}

- (void)showResultsView {
    // Slide down and make the masking view disapear
    self.resultsView.alpha = 0;
    CGRect resultFrame = self.resultsView.frame;
    resultFrame.origin.y = 665;
    self.resultsView.frame = resultFrame;
}

- (void)showInputOnlyView {
    // Slide up the masking field and increase alpha
    self.resultsView.alpha = 1;
    CGRect resultFrame = self.resultsView.frame;
    resultFrame.origin.y = 135;
    self.resultsView.frame = resultFrame;
}

- (void)showResultsViewWithAnimation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            [self showResultsView];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        [self showResultsView];
    }
}

- (void)showInputOnlyViewWithAnimation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            [self showInputOnlyView];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        [self showInputOnlyView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"view will disappear");
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view did disappear");
}

@end
