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



#import "UMNetworkManager.h"

#import "UMStation.h"
#import "UMArrival.h"

@implementation UMNetworkManager

NSString* const kAPIAppId = @"cfc92e34";
NSString* const kAPIAppKey = @"885f8fc8556a1ee28386342c0c511085";
NSString* const kBaseURL = @"https://api.tfl.gov.uk/";
NSString* const kNearbyStopsURL = @"stoppoint/";
NSString* const kArrivalsURL = @"%@/arrivals/";

+ (NSURLSessionDataTask *) unifiedAPI:(CLLocationCoordinate2D)loc callback:(void (^)(NSArray * , NSError* ))callback {
    
    AFHTTPSessionManager * sessionManager = [[AFHTTPSessionManager alloc] init];
    
    /*
     TfL API's responses are JSON. Using AFNetwork's JSON serializer.
     */
    
    sessionManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    
    NSDictionary* params = @{ @"lat" : [NSString stringWithFormat:@"%f", loc.latitude],
                              @"lon" : [NSString stringWithFormat:@"%f", loc.longitude],
                              @"stopTypes" : @"NaptanMetroStation",
                              @"app_id" : kAPIAppId,
                              @"app_key" : kAPIAppKey,
                              @"radius" : @"500"};
    
    
    NSString *api_url = [kBaseURL stringByAppendingString:kNearbyStopsURL];
    
    return [sessionManager GET:api_url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self unifiedApiSuccess:responseObject callback:callback];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil, error);
    }];
}

+ (void) unifiedApiSuccess:(NSDictionary *)response callback:(void (^)(NSArray *, NSError*))callback {
    
    //Create Station objects from serialized dictionary
    
    NSArray* stops = [response objectForKey:@"stopPoints"];
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for (NSDictionary *stop in stops) {
        
        UMStation * s = [[UMStation alloc] init];
        s.location = CLLocationCoordinate2DMake([[stop valueForKey: @"lat"] doubleValue], [[stop valueForKey: @"lon"] doubleValue]);
        s.distance = [[stop valueForKey: @"distance"] doubleValue];
        s.stopDescription = [stop objectForKey:@"commonName"];
        s.stationId = [stop objectForKey:@"naptanId"];
        
        s.facilities = [[NSMutableArray alloc] init];
        
        for(NSDictionary * property in [stop objectForKey:@"additionalProperties"]) {
            if([[[property objectForKey:@"category"] lowercaseString] isEqualToString:@"facility"])
                [s.facilities addObject:@{[property objectForKey:@"key"] : [property objectForKey:@"value"]}];
        }
        
        [result addObject:s];
    }
    
    //Sort by soonest to arrive
    [result sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(UMStation *)obj1 distance] > [(UMStation *)obj2 distance];
    }];
    
    callback(result, nil);
}

+ (NSURLSessionDataTask * _Nonnull) arrivalsForStation:(NSString * _Nonnull)stationId callback:(void (^_Nonnull)(NSArray * _Nullable, NSError* _Nullable))callback {
    
    AFHTTPSessionManager * sessionManager = [[AFHTTPSessionManager alloc] init];
    sessionManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    
    NSString* api_url = [[[kBaseURL stringByAppendingString:kNearbyStopsURL] stringByAppendingString:kArrivalsURL] stringByReplacingOccurrencesOfString:@"%@" withString:stationId];
    
    NSDictionary* params = @{ @"app_id" : kAPIAppId,
                              @"app_key" : kAPIAppKey };
    
    return [sessionManager GET:api_url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self arrivalsSuccess:responseObject callback:callback];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil, error);
    }];
    
}

+ (void) arrivalsSuccess:(NSArray *)arrivals callback:(void (^)(NSArray *, NSError*))callback {
    
    //Create Station objects from serialized dictionary
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for (NSDictionary *arrival in arrivals) {
        
        UMArrival * a = [[UMArrival alloc] init];
        a.lineId = [arrival valueForKey:@"lineId"];
        a.lineName = [arrival valueForKey:@"lineName"];
        a.platformName = [arrival valueForKey:@"platformName"];
        a.direction = [arrival valueForKey:@"direction"];
        a.destinationName = [arrival valueForKey:@"destinationName"];
        a.towards = [arrival valueForKey:@"towards"];
        a.currentLocation = [arrival valueForKey:@"currentLocation"];
        a.timeToStation = [[arrival valueForKey:@"timeToStation"] doubleValue];
        
        [result addObject:a];
    }
    
    //Sort by soonest to arrive
    [result sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(UMArrival *)obj1 timeToStation] > [(UMArrival *)obj2 timeToStation];
    }];
    
    callback(result, nil);
}


@end
