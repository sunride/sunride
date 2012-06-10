//
//  SRReportViewController.m
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import "SRReportViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface SRReportViewController ()

@end

@implementation SRReportViewController {
    CPTGraphHostingView *_comparisionGraphHostView;
    NSDictionary *_combinationData;
}

@synthesize mph=_mph,mileage=_mileage,carID=_carID,zipcode=_zipcode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)reloadData {
   
}

- (void)ceateComparsionGraphLayerForBounds:(CGRect)bounds {
    CPTGraph *graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:bounds];
    
}

- (void)loadView {
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.view = mainScrollView;
    
    _comparisionGraphHostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    
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
