//
//  SRReportViewController.h
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface SRReportViewController : UIViewController <CPTBarPlotDataSource,CPTBarPlotDelegate, UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, copy) NSString *mileage;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, copy) NSString *mpg;
@property (nonatomic, copy) NSString *carID;
@property (nonatomic, copy) NSDictionary *carData;



@end
