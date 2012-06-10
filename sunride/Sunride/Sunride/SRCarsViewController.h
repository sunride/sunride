//
//  UICarsViewController.h
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRCarsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,copy) NSString *zipcode;

@property (nonatomic,copy) NSString *mileage;

@property (nonatomic,copy) NSString *mpg;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)doBackButton:(id)sender;

@end
