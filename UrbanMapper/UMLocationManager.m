/**
 * MIT License
 *
 * Copyright 2017 Joseph Kalash
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "UMLocationManager.h"

#define CENTRAL_LONDON CLLocationCoordinate2DMake(51.508530, -0.125740)

@implementation UMLocationManager

@synthesize newLocationCallback;

CLLocationManager * locationManager;
CLLocation* currentLocation = NULL;

-(id)init:(UMNewLocationBlock)newLocationBlock {
    self = [super init];
    if (self) {
        self.newLocationCallback = newLocationBlock;
        
        locationManager  = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        [self beginUpdatingLocation];
    }
    
    return self;
}

- (void)checkNewLocationInLondon {
    
    if(currentLocation == NULL)
        newLocationCallback(CENTRAL_LONDON, YES);
    
    /*
     The city of London is a particular case as the bounding polygon can
     be approximated by a circle and thus testing a location's presence in London would be testing its distance from the center of london.
     More generally, and for cities whose bounds are polygons, can use CoreLocation's geocoder to reverse geocode a location.
     */
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        BOOL inLondon = NO;
        for (CLPlacemark *p in placemarks) {
            if([[p.locality lowercaseString] isEqualToString:@"london"]) {
                inLondon = YES;
                break;
            }
        }
        
        newLocationCallback(inLondon ? currentLocation.coordinate : CENTRAL_LONDON, inLondon);
        
    }];
    
}

- (void) beginUpdatingLocation {
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        [locationManager requestWhenInUseAuthorization];
 
    currentLocation = NULL;
    [locationManager startUpdatingLocation];
    
    [self checkNewLocationInLondon];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if( status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
       [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    currentLocation = [locations lastObject];
    [self checkNewLocationInLondon];
}

@end
