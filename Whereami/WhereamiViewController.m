//
//  WhereamiViewController.m
//  Andrew Ash

#import "WhereamiViewController.h"
#import "BNRMapPoint.h"

@interface WhereamiViewController ()

@end

@implementation WhereamiViewController




- (void)findLocation
{
    [locationManager startUpdatingLocation];
    [activityIndicator startAnimating];
    [locationTitleField setHidden:YES];
}

- (void)foundLocation:(CLLocation *)loc
{
    CLLocationCoordinate2D coord = [loc coordinate];
    
    // Create an instance of BNRMapPoint with the current data
    BNRMapPoint *mp = [[BNRMapPoint alloc] initWithCoordinate:coord
                                                         title:[locationTitleField text]];
    
    // Add it to the map view
    [worldView addAnnotation:mp];
    
    // Zoom the region to this location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
    [worldView setRegion:region animated:YES];
    
    // Reset the UI
    [locationTitleField setText:@""];
    [activityIndicator stopAnimating];
    [locationTitleField setHidden:NO];
    [locationManager stopUpdatingLocation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // This method isn't implemented yet - but will be soon
    [self findLocation];
    
    [textField resignFirstResponder];
    
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Create location manager object
        locationManager = [[CLLocationManager alloc] init];
        
        [locationManager setDelegate:self];  // ignore this warning
        
        // And we want it to be as accurate as possible
        //  regardless of how much time/power it takes
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        //------------------------------------------------------------------------------------
        // Assignment #1, Q3 (Ch. 4, Bronze Challenge)
        [locationManager setDistanceFilter:50.0];
        //====================================================================================
                
        //------------------------------------------------------------------------------------
        // Assignment #1, Q4 (Ch. 4, Silver Challenge)

        // Start heading updates.
        if ([CLLocationManager headingAvailable]) {
            // Warning: test this code path on a device, not in iPhone Simulator
            // "heading information is available only for devices that contain a hardware compass" (docs)
            [locationManager setHeadingFilter:5];
            [locationManager startUpdatingHeading];
        }
        else {
            NSLog(@"warning: heading information not available for this device/simulator");
        }
        //====================================================================================
    }
    
    return self;
}

- (void)viewDidLoad
{
    [worldView setShowsUserLocation:YES];
}

- (void)dealloc
{
    // Tell the location manager to stop sending us messages
    //   FYI - needed b/c delegate is __unsafe_unretained, so ARC doesn't apply
    [locationManager setDelegate:nil];
}

- (void)mapView:(MKMapView *)mapView
    didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [worldView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager
    didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

//------------------------------------------------------------------------------------
// Assignment #1, Q4 (Ch. 4, Silver Challenge)
// - uses best practices from "Getting Direction-Related Events" in iOS 6.1 docs
- (void)locationManager:(CLLocationManager *)manager
    didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0 )
        return;
    
    // Log true heading if valid, o/w log magnetic heading
    CLLocationDirection theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    NSLog(@"User's heading is %f", theHeading);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return true;
}
//====================================================================================

@end
