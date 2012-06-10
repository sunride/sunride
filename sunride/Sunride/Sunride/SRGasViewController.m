//
//  SRGasViewController.m
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import "SRGasViewController.h"
#import "SRCarsViewController.h"

@interface SRGasViewController ()

@end

@implementation SRGasViewController 

@synthesize mileage=_mileage;
@synthesize mpgField = _mpgField;
@synthesize zipcode=_zipcode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self mpgField] becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMpgField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber* candidateNumber;
    
    NSString* candidateString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    range = NSMakeRange(0, [candidateString length]);
    
    [numberFormatter getObjectValue:&candidateNumber forString:candidateString range:&range error:nil];
    
    if (([candidateString length] > 0) && (candidateNumber == nil || range.length < [candidateString length])) {
        
        return NO;
    }
    else 
    {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowCars"])
    {
        SRCarsViewController *vc = [segue destinationViewController];
        vc.zipcode = _zipcode;
        vc.mileage = _mileage;
        vc.mpg = [_mpgField text];
    }
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSegueWithIdentifier:@"ShowCars" sender:self];
    return NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)doBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
