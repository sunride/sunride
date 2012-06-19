//
//  SRModelController.h
//  TestApp
//
//  Created by Zac Bowling on 6/10/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRDataViewController;

@interface SRModelController : NSObject <UIPageViewControllerDataSource>

- (SRDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(SRDataViewController *)viewController;

@end
