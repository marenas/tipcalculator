//
//  SettingViewController.m
//  tipcalculator
//
//  Created by Matias Arenas Sepulveda on 9/28/15.
//  Copyright (c) 2015 Matias Arenas Sepulveda. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *minTipPercentage;
@property (weak, nonatomic) IBOutlet UITextField *midTipPercentage;
@property (weak, nonatomic) IBOutlet UITextField *maxTipPercentage;
- (IBAction)onTap:(id)sender;
- (void)settingUpdateValues;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIColor *clearBlue = [UIColor colorWithRed:147.0f/255.0f green:213.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    self.minTipPercentage.layer.borderColor= clearBlue.CGColor;
    self.minTipPercentage.layer.borderWidth=1.0f;
    self.minTipPercentage.layer.cornerRadius = 5;

    self.midTipPercentage.layer.borderColor= clearBlue.CGColor;
    self.midTipPercentage.layer.borderWidth=1.0f;
    self.midTipPercentage.layer.cornerRadius = 5;

    self.maxTipPercentage.layer.borderColor= clearBlue.CGColor;
    self.maxTipPercentage.layer.borderWidth=1.0f;
    self.maxTipPercentage.layer.cornerRadius = 5;

    NSLog(@"setting view did load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingUpdateValues {
    float minTipPercentage = [self.minTipPercentage.text floatValue];
    float midTipPercentage = [self.midTipPercentage.text floatValue];
    float maxTipPercentage = [self.maxTipPercentage.text floatValue];
    
    NSLog(@"%@",self.minTipPercentage.text);
    NSLog(@"%0.2f", minTipPercentage);
    NSLog(@"setting update values");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:minTipPercentage forKey:@"min_tip_percentage"];
    [defaults setFloat:midTipPercentage forKey:@"mid_tip_percentage"];
    [defaults setFloat:maxTipPercentage forKey:@"max_tip_percentage"];
    [defaults synchronize];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float min_percentage = [defaults floatForKey:@"min_tip_percentage"];
    float mid_percentage = [defaults floatForKey:@"mid_tip_percentage"];
    float max_percentage = [defaults floatForKey:@"max_tip_percentage"];
    [self.minTipPercentage setText:[NSString stringWithFormat:@"%0.2f", min_percentage]];
    [self.midTipPercentage setText:[NSString stringWithFormat:@"%0.2f", mid_percentage]];
    [self.maxTipPercentage setText:[NSString stringWithFormat:@"%0.2f", max_percentage]];
    NSLog(@"setting view will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"setting view did appear");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"setting view will disappear");
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"setting view did disappear");
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
    [self settingUpdateValues];
}
@end
