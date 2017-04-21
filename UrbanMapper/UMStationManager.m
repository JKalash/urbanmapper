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


#import "UMStationManager.h"

#import "UMNetworkManager.h"
#import "UMLocationManager.h"

@interface UMStationManager ()

@property(nonatomic, retain)UMLocationManager * locManager;

@end

@implementation UMStationManager

@synthesize locManager, delegate, nearbyStations;

NSTimer *refreshArrivalsTimer;
BOOL previousLocationInLondon = YES;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        locManager = [[UMLocationManager alloc] init:^(CLLocationCoordinate2D location, BOOL inLondon) {
            [self refreshStations:location];
            
            if(previousLocationInLondon && !inLondon)
                [delegate stationsManagerDetectedOutOfLondonLocation:self];
            
            previousLocationInLondon = inLondon;
        }];
        
        nearbyStations = [NSMutableArray new];
        
        refreshArrivalsTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateStationArrivals) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc {
    [refreshArrivalsTimer invalidate];
    
}

-(void)refreshStations:(CLLocationCoordinate2D)location {
    
    [UMNetworkManager unifiedAPI:location callback:^(NSArray* results, NSError* error) {
        
        if (error) {
            [delegate stationsManagerErrorRefreshing:error];
            return;
        }
        
        //Prevent refresh timer from being called right away
        if(refreshArrivalsTimer) {
            [refreshArrivalsTimer invalidate];
            refreshArrivalsTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateStationArrivals) userInfo:nil repeats:YES];
        }
        
        [self.nearbyStations removeAllObjects];
        [self.nearbyStations addObjectsFromArray:results];

        [delegate stationManagerRefreshedStations:self];
        
        [self updateStationArrivals];
        
    }];
}

-(void)updateStationArrivals {
    
    for (UMStation* s in nearbyStations) {
        
        [UMNetworkManager arrivalsForStation:s.stationId callback:^(NSArray * arrivals, NSError * error) {
            
            if (error) {
                return;
            }
            
            [s.arrivals removeAllObjects];
            [s.arrivals addObjectsFromArray:arrivals];
            [delegate stationManager:self refreshedArrivalsForStation:s];
        }];
        
    }
    
}

@end
