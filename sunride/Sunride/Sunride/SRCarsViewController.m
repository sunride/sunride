//
//  UICarsViewController.m
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import "SRCarsViewController.h"
#import "SRReportViewController.h"


@interface SRCarsViewController ()

@end

@implementation SRCarsViewController {
    NSArray *_cars;
}

@synthesize mileage=_mileage;
@synthesize zipcode=_zipcode;
@synthesize mpg=_mpg;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadCarData {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://solarlistapi.com/api/cars.json"]];
   
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
        if (!error && httpReponse.statusCode >= 200 && httpReponse.statusCode < 300) {
            NSArray *rawCars = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"make" ascending:YES];
            _cars = [rawCars sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            if (self.isViewLoaded) {
                [self.tableView reloadData];
            }
        }
        else {
            NSLog(@"error: %@ request %@ response: %@", error, request, response);
        }
    }];
}


- (void)awakeFromNib {
    [self loadCarData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadCarData];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cars count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    NSDictionary *carData = [_cars objectAtIndex:indexPath.row];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 640, 180)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UILabel *carNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 400, 30)];
    
    
    NSString *carName = [NSString stringWithFormat:@"%@ - %@", [carData objectForKey:@"make"], [carData objectForKey:@"car_model"]];
    carNameLabel.text = carName;

    carNameLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    carNameLabel.backgroundColor = [UIColor clearColor];
    carNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

    [contentView addSubview:carNameLabel];
    
    UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 300, 120)];
    detailsLabel.numberOfLines = 0;
    
    NSMutableString *detailString = [[NSMutableString alloc] init];
    [detailString appendFormat:@" \u2022 %@ miles per KWH\n", [carData objectForKey:@"miles_per_kwh"]];
    [detailString appendFormat:@" \u2022 %@ KWH battery capacity\n", [carData objectForKey:@"full_capacity"]];
    [detailString appendFormat:@" \u2022 %@ estimated hours to full charge\n", [carData objectForKey:@"estimated_charge_time"]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
                                
    [detailString appendFormat:@" \u2022 %@ federal tax credit\n", [numberFormatter stringFromNumber:[carData objectForKey:@"federal_tax_credit"]]];
    [detailString appendFormat:@" \u2022 %@ state tax credit\n", [numberFormatter stringFromNumber:[carData objectForKey:@"state_tax_credit"]]];
    [detailString appendFormat:@" \u2022 %@ MSRP\n", [numberFormatter stringFromNumber:[carData objectForKey:@"msrp_low"]]];
    
    detailsLabel.text = [NSString stringWithFormat:detailString];
    detailsLabel.font = [UIFont systemFontOfSize:16.0f];
    detailsLabel.backgroundColor = [UIColor clearColor];
    detailsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [detailsLabel sizeToFit];
    
    [contentView addSubview:detailsLabel];
    
    NSString *imageName = nil;
    NSString *carID = [carData objectForKey:@"id"];
    if ([carID isEqualToString:@"4fd3e181dc149a2c8e000003"]) {
        imageName = @"Chevy_Volt";
    } else if ([carID isEqualToString:@"4fd3e181dc149a2c8e000002"]) {
        imageName = @"Ford_Focus";
    } else if ([carID isEqualToString:@"4fd3e181dc149a2c8e000004"]) {
        imageName = @"Mitsubishi_i";
    } else if ([carID isEqualToString:@"4fd3e181dc149a2c8e000005"]) {
        imageName = @"Nissan_Leaf";
    } else if ([carID isEqualToString:@"4fd3e182dc149a2c8e000006"]) {
        imageName = @"Tesla_Roadster";
    } else if ([carID isEqualToString:@"4fd3e182dc149a2c8e000008"]) {
        imageName = @"Toyota_RAV4_EV";
    } else if ([carID isEqualToString:@"4fd3e182dc149a2c8e000009"]) {
        imageName = @"Wheego_LiFe";
    } else if ([carID isEqualToString:@"4fd3e182dc149a2c8e00000a"]) {
        imageName = @"Tesla_Model_S";
    }
    
    if (imageName) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        imageView.frame = CGRectMake(240, 0, 400, 180);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [contentView addSubview:imageView];
    }

    
    contentView.backgroundColor = [UIColor clearColor];
    [contentView setFrame:CGRectInset(cell.contentView.bounds, 5, 5)];
    [cell.contentView addSubview:contentView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SRReportViewController *reportController = [[SRReportViewController alloc] init];
    reportController.mpg = _mpg;
    reportController.mileage = _mileage;
    reportController.zipcode = _zipcode;
    
    
    NSDictionary *carData = [_cars objectAtIndex:indexPath.row];

    reportController.carID = [carData objectForKey:@"id"];
    reportController.carData = carData;
    
    __weak SRCarsViewController *weakself = self;
    [self presentViewController:reportController animated:YES completion:^{
        [weakself.tableView deselectRowAtIndexPath:weakself.tableView.indexPathForSelectedRow animated:NO]; 
    }];
}

- (IBAction)doBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
