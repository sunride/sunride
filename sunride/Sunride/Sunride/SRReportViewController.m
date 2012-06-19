//
//  SRReportViewController.m
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import "SRReportViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "SRPageItemViewController.h"
#import <MessageUI/MessageUI.h>

@interface SRReportViewController ()

@end

@implementation SRReportViewController {
    CPTGraphHostingView *_comparisionGraphHostView;
    CPTGraphHostingView *_savingsGraphHostView;
    CPTGraphHostingView *_CO2GraphHostView;
    CPTGraphHostingView *_combinationGraphHostView;
    NSArray *_pageViewControllers;
    UIPageControl *_pageControl;
    NSDictionary *_vehicleData;
    NSDictionary *_combinationData;
    UIPageViewController *_pageController;
}

@synthesize mpg=_mpg,mileage=_mileage,carID=_carID,zipcode=_zipcode,carData=_carData;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)reloadData {
    
    //curl -X POST -d "vehicle[car_id]=4fd3e181dc149a2c8e000001" http://solarlistapi.com/api/vehicles
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://solarlistapi.com/api/vehicles"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        NSString *queryParams = [NSString stringWithFormat:@"vehicle[car_id]=%@&vehicle[zipcode]=%@&vehicle[miles_driven_per_year]=%@&vehicle[miles_per_gallon]=%@",_carID,_zipcode,_mileage,_mpg];
        [request setHTTPBody:[queryParams dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse *response;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        
        _vehicleData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    }
    
    if (!_vehicleData) {
        NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"json"]]; 
        _vehicleData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    }

    /*{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://solarlistapi.com/api/combinations/%@.json",_carID]]];
        [request setHTTPMethod:@"GET"];
                
        NSHTTPURLResponse *response;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        
        _combinationData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    }*/
    
    NSLog(@"data %@",_vehicleData);
    NSLog(@"combination %@",_combinationData);
}

- (void)reloadViewControllers {
    SRPageItemViewController *_coverPageViewController = [[SRPageItemViewController alloc] initWithView:[self createCoverPageView]];
    
    _comparisionGraphHostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    _comparisionGraphHostView.hostedGraph = [self createComparsionGraphLayerForBounds:_comparisionGraphHostView.bounds];
    
    _comparisionGraphHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    SRPageItemViewController *_comparisionGraphPageViewController = [[SRPageItemViewController alloc] initWithView:_comparisionGraphHostView];
    
    _savingsGraphHostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    _savingsGraphHostView.hostedGraph = [self createSavingsGraphLayerForBounds:_savingsGraphHostView.bounds];
    
    _savingsGraphHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    SRPageItemViewController *_savingsGraphPageViewController = [[SRPageItemViewController alloc] initWithView:_savingsGraphHostView];
    
    
    _CO2GraphHostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    _CO2GraphHostView.hostedGraph = [self createCO2GraphLayerForBounds:_CO2GraphHostView.bounds];
    
    _CO2GraphHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    SRPageItemViewController *_CO2GraphPageViewController = [[SRPageItemViewController alloc] initWithView:_CO2GraphHostView];
    
    _combinationGraphHostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    _combinationGraphHostView.hostedGraph = [self createCombinationGraphLayerForBounds:_combinationGraphHostView.bounds];
    
    _combinationGraphHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    SRPageItemViewController *_combinationGraphPageViewController = [[SRPageItemViewController alloc] initWithView:_combinationGraphHostView];
    
    
    SRPageItemViewController *_summaryPageViewController = [[SRPageItemViewController alloc] initWithView:[self createSummaryView]];
    
    
    _pageViewControllers = [NSArray arrayWithObjects:_coverPageViewController,_comparisionGraphPageViewController,_savingsGraphPageViewController,_CO2GraphPageViewController,_combinationGraphPageViewController,_summaryPageViewController, nil];
    
    [_pageController setViewControllers:[NSArray arrayWithObject:_coverPageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
    }];
    
}

- (UIView *)createSummaryView {
    UIView *summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    NSMutableString *detailString = [NSMutableString string];
    [detailString appendString:@"\nReport:\n"];
    [detailString appendFormat:@" \u2022 Current gas car averages %@ MPG\n",_mpg];
    [detailString appendFormat:@" \u2022 Current gas price is $%@ per gallon in zipcode %@\n", @"4.25", _zipcode];
    [detailString appendFormat:@" \u2022 Current commute average is %@ miles per year\n", _mileage];
    [detailString appendFormat:@" \u2022 Best KHW rate in zipcode %@ is %@ (assuming any EV rate discounts)\n", _zipcode, [numberFormatter stringFromNumber:[NSNumber numberWithDouble:([[_vehicleData objectForKey:@"average_rate"] doubleValue]/100.0)]]];
    
    [detailString appendFormat:@"\n%@ %@:\n",[_carData objectForKey:@"make"],[_carData objectForKey:@"car_model"]];
    [detailString appendFormat:@" \u2022 %@ miles per KWH\n", [_carData objectForKey:@"miles_per_kwh"]];
    [detailString appendFormat:@" \u2022 %@ KWH battery capacity\n", [_carData objectForKey:@"full_capacity"]];
    [detailString appendFormat:@" \u2022 %@ estimated hours to full charge\n", [_carData objectForKey:@"estimated_charge_time"]];
    [detailString appendFormat:@" \u2022 %@ battery efficiency \n", [_vehicleData objectForKey:@"battery_efficiency"]];
    
    [detailString appendFormat:@" \u2022 %@ federal tax credit\n", [numberFormatter stringFromNumber:[_carData objectForKey:@"federal_tax_credit"]]];
    [detailString appendFormat:@" \u2022 %@ state tax credit\n", [numberFormatter stringFromNumber:[_carData objectForKey:@"state_tax_credit"]]];
    [detailString appendFormat:@" \u2022 %@ MSRP\n", [numberFormatter stringFromNumber:[_carData objectForKey:@"msrp_low"]]];
    [detailString appendFormat:@" \u2022 %@ CO2 emissions reduced\n", [_vehicleData objectForKey:@"co2_emissions_reduced"]];
    [detailString appendFormat:@" \u2022 %@ annual KWH required\n", [_vehicleData objectForKey:@"annual_kwh_required"]];
    [detailString appendFormat:@" \u2022 %@ average monthly cost\n",[numberFormatter stringFromNumber:[_vehicleData objectForKey:@"average_monthly_cost"]]];
    [detailString appendFormat:@" \u2022 %@ hours to charge daily\n",[_vehicleData objectForKey:@"daily_charge_time"]];
    [detailString appendFormat:@" \u2022 %d%% of battery used daily\n",(int)([[_vehicleData objectForKey:@"percentage_of_battery_used_daily"] doubleValue]*100.0)];
    
    
    UILabel *summaryDetailsLabel = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, 1024, 728), 40, 40)];
    summaryDetailsLabel.numberOfLines = 0;
    summaryDetailsLabel.text = detailString;
    summaryDetailsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [summaryView addSubview:summaryDetailsLabel];
    
    NSString *imageName = nil;
    NSString *carID = [_carData objectForKey:@"id"];
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
        imageView.frame = CGRectMake(1024-400, 0, 400, 300);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [summaryView addSubview:imageView];
    }
    
    summaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return summaryView;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [_pageViewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    else {
        return [_pageViewControllers objectAtIndex:(index-1)];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [_pageViewControllers indexOfObject:viewController];
    if (index+1 == [_pageViewControllers count] || index == NSNotFound) {
        return nil;
    }
    else {
        return [_pageViewControllers objectAtIndex:(index+1)];
    }
}


- (CPTGraph *)createSavingsGraphLayerForBounds:(CGRect)bounds {
    CPTGraph *graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:bounds];
    [graph setTitle:@"Savings"];
    
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.f) length:CPTDecimalFromFloat(11.5f)];
	barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-500.0f) length:CPTDecimalFromFloat(11000.0f)];
    [graph addPlotSpace:barPlotSpace];
    
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 1.0f;
	majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
    x.majorIntervalLength		  = CPTDecimalFromInteger(1);
    x.minorTicksPerInterval		  = 0;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //x.majorGridLineStyle = majorGridLineStyle;
    x.axisLineStyle		 = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.labelOffset		 = 10.0;
    
    x.title		  = @"Time in years";
    x.titleOffset = 30.0f;
    
    x.plotSpace = barPlotSpace;
    
    CPTXYAxis *y		  = axisSet.yAxis;
    y.majorIntervalLength		  = CPTDecimalFromInteger(1);
    y.minorTicksPerInterval		  = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //y.majorGridLineStyle = majorGridLineStyle;
    y.axisLineStyle		 = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.labelOffset		 = 10.0;
    
    y.title		  = @"Savings";
    y.titleOffset = 30.0f;
    y.labelRotation				  = M_PI / 2;
    y.labelingPolicy			  = CPTAxisLabelingPolicyAutomatic;
    y.plotSpace = barPlotSpace;
    
    // Create first bar plot
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:1.0f blue:0.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(0.0f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.8f); // bar is 50% of the available space
	barPlot.barCornerRadius = 10.0f;
    barPlot.barsAreHorizontal = NO;
    
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color   = [CPTColor blackColor];
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"savings_over_gas";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    return graph;
}

- (CPTGraph *)createComparsionGraphLayerForBounds:(CGRect)bounds {
    CPTGraph *graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:bounds];
    [graph setTitle:@"Cost of Gas vs EVP"];
    
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.f) length:CPTDecimalFromFloat(11.5f)];
	barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-500.0f) length:CPTDecimalFromFloat(11000.0f)];
    [graph addPlotSpace:barPlotSpace];
    
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 1.0f;
	majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
    x.majorIntervalLength		  = CPTDecimalFromInteger(1);
    x.minorTicksPerInterval		  = 0;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //x.majorGridLineStyle = majorGridLineStyle;
    x.axisLineStyle		 = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.labelOffset		 = 10.0;
    
    x.title		  = @"Time in years";
    x.titleOffset = 30.0f;
    
    x.plotSpace = barPlotSpace;
    
    CPTXYAxis *y		  = axisSet.yAxis;
    y.majorIntervalLength		  = CPTDecimalFromInteger(1);
    y.minorTicksPerInterval		  = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //y.majorGridLineStyle = majorGridLineStyle;
    y.axisLineStyle		 = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.labelOffset		 = 10.0;

    y.title		  = @"Cost";
    y.titleOffset = 30.0f;
    y.labelRotation				  = M_PI / 2;
    y.labelingPolicy			  = CPTAxisLabelingPolicyAutomatic;
    y.plotSpace = barPlotSpace;
    
    // Create first bar plot
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(0.0f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.45f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color   = [CPTColor blackColor];
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"gas_costs";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:0.0f blue:1.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(.450f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.45f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"electricity_costs";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];

    return graph;
}

- (CPTGraph *)createCombinationGraphLayerForBounds:(CGRect)bounds {
    CPTGraph *graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:bounds];
    [graph setTitle:@"Cost differences"];
    
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.f) length:CPTDecimalFromFloat(11.5f)];
	barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-500.0f) length:CPTDecimalFromFloat(11000.0f)];
    [graph addPlotSpace:barPlotSpace];
    
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 1.0f;
	majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
    x.majorIntervalLength		  = CPTDecimalFromInteger(1);
    x.minorTicksPerInterval		  = 0;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //x.majorGridLineStyle = majorGridLineStyle;
    x.axisLineStyle		 = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.labelOffset		 = 10.0;
    
    x.title		  = @"Time in years";
    x.titleOffset = 30.0f;
    
    x.plotSpace = barPlotSpace;
    
    CPTXYAxis *y		  = axisSet.yAxis;
    y.majorIntervalLength		  = CPTDecimalFromInteger(1);
    y.minorTicksPerInterval		  = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //y.majorGridLineStyle = majorGridLineStyle;
    y.axisLineStyle		 = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.labelOffset		 = 10.0;
    
    y.title		  = @"Cost";
    y.titleOffset = 30.0f;
    y.labelRotation				  = M_PI / 2;
    y.labelingPolicy			  = CPTAxisLabelingPolicyAutomatic;
    y.plotSpace = barPlotSpace;
    
    // Create first bar plot
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
	barPlot.barBasesVary	= YES;
    barPlot.barOffset       = CPTDecimalFromDouble(0.0f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.45f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"gas_costs_before";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:0.0f blue:1.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(0.0f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.45f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color   = [CPTColor blackColor];
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"electric_costs_before";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    
    barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:1.0f blue:0.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(.450f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.45f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"electric_costs_after";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    return graph;
}


- (CPTGraph *)createCO2GraphLayerForBounds:(CGRect)bounds {
    CPTGraph *graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:bounds];
    [graph setTitle:@"CO savings"];
    
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-.125f) length:CPTDecimalFromFloat(2.0f)];
	barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-100.0f) length:CPTDecimalFromFloat(24000.0f)];
    [graph addPlotSpace:barPlotSpace];
    
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 1.0f;
	majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
    x.majorIntervalLength		  = CPTDecimalFromInteger(1);
    x.minorTicksPerInterval		  = 0;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //x.majorGridLineStyle = majorGridLineStyle;
    x.axisLineStyle		 = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.labelOffset		 = 10.0;
    
    //x.title		  = @"Time in years";
    x.titleOffset = 30.0f;
    
    x.plotSpace = barPlotSpace;
    
    CPTXYAxis *y		  = axisSet.yAxis;
    y.majorIntervalLength		  = CPTDecimalFromInteger(1);
    y.minorTicksPerInterval		  = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    //y.majorGridLineStyle = majorGridLineStyle;
    y.axisLineStyle		 = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.labelOffset		 = 10.0;
    
    y.title		  = @"CO2";
    y.titleOffset = 30.0f;
    y.labelRotation				  = M_PI / 2;
    y.labelingPolicy			  = CPTAxisLabelingPolicyAutomatic;
    y.plotSpace = barPlotSpace;
    
    // Create first bar plot
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(.75f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.25f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color   = [CPTColor blackColor];
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"co2_emissions_from_gas";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    barPlot = [[CPTBarPlot alloc] init];
	barPlot.fill			= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:0.0f blue:1.0f alpha:1.0f]];
	barPlot.barBasesVary	= NO;
    barPlot.barOffset       = CPTDecimalFromDouble(1.25f);
	barPlot.barWidth		= CPTDecimalFromFloat(0.25f); // bar is 50% of the available space
	barPlot.barCornerRadius = 0.0f;
    barPlot.barsAreHorizontal = NO;
    
	barPlot.labelTextStyle = whiteTextStyle;
    
	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"co2_emissions_from_electricity";
    
    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
    
    return graph;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([plot.identifier isEqual:@"gas_costs"]) {
        return [[_vehicleData objectForKey:@"gas_costs_before"] count];
    } else if ([plot.identifier isEqual:@"electricity_costs"]) {
        return [[_vehicleData objectForKey:@"electric_costs_before"] count];
    } else if ([plot.identifier isEqual:@"savings_over_gas"]) {
        return [[_vehicleData objectForKey:@"savings_over_gas"] count];
    } else if ([plot.identifier isEqual:@"electric_costs_before"]) {
        return [[_vehicleData objectForKey:@"electric_costs_before"] count];
    } else if ([plot.identifier isEqual:@"gas_costs_before"]) {
        return [[_vehicleData objectForKey:@"gas_costs_before"] count];
    } else if ([plot.identifier isEqual:@"electric_costs_after"]) {
        return [[_vehicleData objectForKey:@"electric_costs_after"] count];
    } else if ([plot.identifier isEqual:@"co2_emissions_from_gas"] || [plot.identifier isEqual:@"co2_emissions_from_electricity"]  ) {
        return 1;
    }
	return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id data;
    if ([plot.identifier isEqual:@"gas_costs"]) {
        data = [[_vehicleData objectForKey:@"gas_costs_before"] objectAtIndex:index];
    } else  if ([plot.identifier isEqual:@"electricity_costs"]) {
        data = [[_vehicleData objectForKey:@"electric_costs_before"] objectAtIndex:index];
    } else if ([plot.identifier isEqual:@"savings_over_gas"]) {
        data = [[_vehicleData objectForKey:@"savings_over_gas"] objectAtIndex:index];
    } else if ([plot.identifier isEqual:@"co2_emissions_from_gas"]) {
        data = [_vehicleData objectForKey:@"co2_emissions_from_gas"];
    } else if ([plot.identifier isEqual:@"co2_emissions_from_electricity"]) {
        data = [_vehicleData objectForKey:@"co2_emissions_from_electricity"];
    } else if ([plot.identifier isEqual:@"electric_costs_before"]) {
        data = [[_vehicleData objectForKey:@"electric_costs_before"] objectAtIndex:index];
    } else if ([plot.identifier isEqual:@"gas_costs_before"]) {
        data = [[_vehicleData objectForKey:@"gas_costs_before"] objectAtIndex:index];
    } else if ([plot.identifier isEqual:@"electric_costs_after"]) {
        data = [[_vehicleData objectForKey:@"electric_costs_after"] objectAtIndex:index];
    } 
    
    switch ( fieldEnum ) {
        case CPTBarPlotFieldBarLocation:
            return [NSDecimalNumber numberWithUnsignedInteger:index];
        case CPTBarPlotFieldBarBase:
            if ([plot.identifier isEqual:@"gas_costs_before"]){
                return [[_vehicleData objectForKey:@"electric_costs_before"] objectAtIndex:index];
            }
            return [NSDecimalNumber numberWithUnsignedInteger:0];
        case CPTBarPlotFieldBarTip:
            if ([plot.identifier isEqual:@"gas_costs_before"]){
                double tip = [data doubleValue] + [[[_vehicleData objectForKey:@"electric_costs_before"] objectAtIndex:index] doubleValue];
                return [NSNumber numberWithDouble:tip];
            }
            return data;
        default:
            return nil;
    }
}

- (IBAction)doSend:(id)sender {
    
}

- (IBAction)doDone:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
}


- (UIView *)createCoverPageView {
    UIView *coverPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    
    UILabel *dealerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 1024, 50)];
    dealerLabel.font = [UIFont boldSystemFontOfSize:48.0f];
    dealerLabel.text = @"Wild-West Ford";
    dealerLabel.textAlignment = UITextAlignmentCenter;
    [coverPageView addSubview:dealerLabel];
    dealerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    UILabel *subDealerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 290, 1024, 30)];
    subDealerLabel.font = [UIFont systemFontOfSize:24.0f];
    subDealerLabel.text = @"1 (555) CHEAP-EV";
    subDealerLabel.textAlignment = UITextAlignmentCenter;
    subDealerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [coverPageView addSubview:subDealerLabel];
    
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 1024, 40)];
    dataLabel.font = [UIFont boldSystemFontOfSize:36.0f];
    dataLabel.text = [NSString stringWithFormat:@"Personalized report for %@ %@",
                      [_carData objectForKey:@"make"],
                      [_carData objectForKey:@"car_model"]];
    dataLabel.textAlignment = UITextAlignmentCenter;
    dataLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [coverPageView addSubview:dataLabel];
    coverPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return coverPageView;
}


- (void)loadView {
    [self reloadData];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    
    containerView.backgroundColor = [UIColor blackColor];
    
    NSDictionary * options = [NSDictionary dictionaryWithObject:
                              [NSNumber numberWithInt:UIPageViewControllerSpineLocationMin]
                                                         forKey:UIPageViewControllerOptionSpineLocationKey];
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    _pageController.dataSource = self;
    
    [self addChildViewController:_pageController];
    
    UIView *bookBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 728)];
    bookBackView.backgroundColor = [UIColor lightGrayColor];
    [bookBackView addSubview:_pageController.view];
    bookBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    [_pageController.view setFrame:CGRectInset(bookBackView.bounds, 20, 20)];
    [_pageController didMoveToParentViewController:self];
    
    [self reloadViewControllers];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, 728, 120, 40);
    [sendButton setTitle:@"Email" forState:UIControlStateNormal];
    sendButton.titleLabel.textColor = [UIColor whiteColor];
    sendButton.backgroundColor = [UIColor darkGrayColor];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [sendButton addTarget:self action:@selector(doSend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];
    printButton.frame = CGRectMake(130, 728, 120, 40);
    [printButton setTitle:@"Print" forState:UIControlStateNormal];
    printButton.titleLabel.textColor = [UIColor whiteColor];
    printButton.backgroundColor = [UIColor darkGrayColor];
    printButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(1024-120, 728, 120, 40);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.backgroundColor = [UIColor darkGrayColor];
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [doneButton addTarget:self action:@selector(doDone:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:printButton];
    [containerView addSubview:sendButton];
    [containerView addSubview:doneButton];
    [containerView addSubview:bookBackView];

    self.view = containerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect frame = [scrollView frame];
    float roundedValue = floor(scrollView.contentOffset.x / frame.size.width);
    _pageControl.currentPage = roundedValue;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
