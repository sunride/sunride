//
//  SRGasViewController.h
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRGasViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic,copy) NSString *zipcode;

@property (nonatomic,copy) NSString *mileage;

@property (weak, nonatomic) IBOutlet UITextField *mpgField;

- (IBAction)doBackButton:(id)sender;

@end
