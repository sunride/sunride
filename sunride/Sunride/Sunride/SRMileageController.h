//
//  SRDrivingControlling.h
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMileageController : UIViewController

@property (nonatomic,copy) NSString *zipcode;

@property (weak, nonatomic) IBOutlet UIButton *heavyButton;
@property (weak, nonatomic) IBOutlet UIButton *moderateButton;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;

- (IBAction)doMileageSelection:(id)sender;
- (IBAction)doBackButton:(id)sender;

@end
