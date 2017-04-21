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


#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

@interface UMNetworkManager : NSObject

/*
 * Static method that calls the unified API to closest tube stations to given loc parameter.
 * Responds with a callback that attempts provides a list of stations with a fallback to standard NSError.
 * @returns a URLSessionDataTask to cancel or track download progress
 */

+ (NSURLSessionDataTask * _Nonnull) unifiedAPI:(CLLocationCoordinate2D)loc callback:(void (^_Nonnull)(NSArray * _Nullable, NSError* _Nullable))callback;


/*
 * Static method that fetches arrivals for a given stationId.
 * Responds with a callback that attempts provides a list of arrivals with a fallback to standard NSError.
 * @returns a URLSessionDataTask to cancel or track download progress
 */

+ (NSURLSessionDataTask * _Nonnull) arrivalsForStation:(NSString * _Nonnull)stationId callback:(void (^_Nonnull)(NSArray * _Nullable, NSError* _Nullable))callback;

@end
