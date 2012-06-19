//
//  SRPageItemViewController.m
//  Sunride
//
//  Created by Zac Bowling on 6/10/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import "SRPageItemViewController.h"

@interface SRPageItemViewController ()

@end

@implementation SRPageItemViewController {
    UIView *_retainedView;
}

- (id)initWithView:(UIView *)view
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _retainedView = view;
    }
    return self;
}

- (void)loadView {
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [baseView addSubview:_retainedView];
    self.view = baseView;
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
