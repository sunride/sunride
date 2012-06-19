//
//  SRDrivingControlling.m
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import "SRMileageController.h"
#import "SRGasViewController.h"

@interface SRMileageController ()

@end

@implementation SRMileageController {
    NSString *_selectedMilegage;
}

@synthesize zipcode=_zipcode;
@synthesize heavyButton = _heavyButton;
@synthesize moderateButton = _moderateButton;
@synthesize lightButton = _lightButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setLightButton:nil];
    [self setModerateButton:nil];
    [self setHeavyButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowGas"])
    {
        SRGasViewController *vc = [segue destinationViewController];
        vc.zipcode = _zipcode;
        vc.mileage = _selectedMilegage;
    }
}


- (IBAction)doMileageSelection:(id)sender {
    if (sender == _lightButton) {
        _selectedMilegage = @"7500";
    } else if (sender == _moderateButton) {
        _selectedMilegage = @"15000";
    } else {
        _selectedMilegage = @"20000";
    }
    [self performSegueWithIdentifier:@"ShowGas" sender:self];
}

- (IBAction)doBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
