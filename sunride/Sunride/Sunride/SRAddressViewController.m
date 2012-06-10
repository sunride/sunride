//
//  SRAddressViewController.m
//  Sunride
//
//  Created by Zac Bowling on 6/9/12.
//  Copyright (c) 2012 View.io. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "SRAddressViewController.h"
#import "SRMileageController.h"

@interface SRAddressViewController ()

@end

@implementation SRAddressViewController {
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    NSArray *_currentAnnotations;
    NSMutableDictionary *_annotationAddressDict;
    NSString *_selectedZip;
    BOOL firstLocationFound;
}
@synthesize mapView=_mapView;
@synthesize addressTextField=_addressTextField;
@synthesize searchButton=_searchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    _currentAnnotations = [NSArray array];
    _geocoder = [[CLGeocoder alloc] init];
    _annotationAddressDict = [NSMutableDictionary dictionary];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
	firstLocationFound = NO;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!firstLocationFound) {
        firstLocationFound = YES;
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;  
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = .75; // Change these values to change the zoom
        span.longitudeDelta = .75; 
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
}

- (void)viewDidUnload
{
    [self.mapView setDelegate:nil];
    [self setMapView:nil];
    [self setAddressTextField:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMileage"])
    {
        SRMileageController *vc = [segue destinationViewController];
        vc.zipcode = _selectedZip;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    NSString *zip = [_annotationAddressDict objectForKey:[NSValue valueWithNonretainedObject:view.annotation]];
    if (!zip) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
        if (_geocoder.isGeocoding) {
            [_geocoder cancelGeocode];
        }
        
        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSLog(@"address selected %@", [placemark addressDictionary]);
                _selectedZip = [placemark.addressDictionary objectForKey:@"ZIP"];
                [self performSegueWithIdentifier:@"ShowMileage" sender:self];
            }
        }];
    }
    else {
        _selectedZip = zip;
        [self performSegueWithIdentifier:@"ShowMileage" sender:self];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
    annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinPoint"];
    if ([_currentAnnotations containsObject:annotation]) {
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }
    else 
    {
        annotationView.pinColor = MKPinAnnotationColorPurple;
    }
    annotationView.canShowCallout = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    annotationView.rightCalloutAccessoryView = button;
    return annotationView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self doSearch:self];
    return NO;
}

- (void)zoomToFitMapAnnotations { 
    if ([self.mapView.annotations count] == 0) return; 
    
    CLLocationCoordinate2D topLeftCoord; 
    topLeftCoord.latitude = -90; 
    topLeftCoord.longitude = 180; 
    
    CLLocationCoordinate2D bottomRightCoord; 
    bottomRightCoord.latitude = 90; 
    bottomRightCoord.longitude = -180; 
    
    for(id<MKAnnotation> annotation in self.mapView.annotations) { 
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude); 
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude); 
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude); 
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude); 
    } 
    
    MKCoordinateRegion region; 
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5; 
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;      
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; 
    
    // Add a little extra space on the sides 
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; 
    
    region = [self.mapView regionThatFits:region]; 
    [self.mapView setRegion:region animated:YES]; 
}

- (IBAction)doBackButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doSearch:(id)sender {
    [self.view endEditing:YES];
    if (_geocoder.isGeocoding) {
        [_geocoder cancelGeocode];
    }
    if ([[self.addressTextField text] length] > 0) { 
        MKCoordinateRegion mkregion = self.mapView.region;
        CLLocationDegrees radius = 0;
        if (mkregion.span.latitudeDelta > mkregion.span.longitudeDelta) {
            radius = mkregion.span.latitudeDelta;
        }
        else {
            radius = mkregion.span.longitudeDelta;
        }
        
        [self.mapView removeAnnotations:_currentAnnotations];
        [_annotationAddressDict removeAllObjects];
        CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:self.mapView.centerCoordinate radius:(self.mapView.region.span.latitudeDelta * 2) identifier:@"search area"];
        
        [_geocoder geocodeAddressString:[self.addressTextField text] inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
            [_annotationAddressDict removeAllObjects];
            [self.mapView removeAnnotations:_currentAnnotations];
            NSMutableArray *newAnnotations = [NSMutableArray arrayWithCapacity:[placemarks count]];
            for (CLPlacemark *placemark in placemarks) {
                MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
                pa.coordinate = placemark.location.coordinate;
                pa.title = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                NSString *zip = [placemark.addressDictionary objectForKey:@"ZIP"];
                if (zip)
                    [_annotationAddressDict setObject:zip forKey:[NSValue valueWithNonretainedObject:pa]];
                [newAnnotations addObject:pa];
                [self.mapView addAnnotation:pa];
            }
            _currentAnnotations = newAnnotations;
            [self zoomToFitMapAnnotations];
        }];
    }
    
}

@end
