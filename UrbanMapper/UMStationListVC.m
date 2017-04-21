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


#import "Whisper-Swift.h"
#import "UrbanMapper-Swift.h"

#import "UMStationListVC.h"

#import "UMStation.h"
#import "UMArrival.h"

@interface UMStationListVC ()

@property(nonatomic, strong)UMStationManager* stationManager;

@end

@implementation UMStationListVC

@synthesize stationManager;

NSString* const kHeaderCellIdentifier = @"StationInfoHeader";
NSString* const kFacilityCellIdentifier = @"FeatureCell";
NSString* const kArrivalCellIdentifier = @"ArrivalCell";

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    stationManager = [[UMStationManager alloc] init];
    stationManager.delegate = self;

}

// Intercept push (show) segue to set destinationviewcontroller's title
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender {
    
    UIButton *facility = sender;
    if(facility)
        [segue.destinationViewController setTitle:[facility titleLabel].text];
    
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return stationManager.nearbyStations.count;
}

// Each section has an item for each facility + an item for each arrival (up to 3 arrivals)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    UMStation* s = [stationManager.nearbyStations objectAtIndex:section];
    return s.facilities.count + MIN(3, s.arrivals.count);
}

// Section headers contain station name and distance
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if(kind != UICollectionElementKindSectionHeader)
        return nil;
    
    UMStation* s = stationManager.nearbyStations[indexPath.section];
    
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellIdentifier forIndexPath:indexPath];
    
    [(UILabel *)[header viewWithTag:1] setText:s.stopDescription];
    [(UILabel *)[header viewWithTag:2] setText:[NSString stringWithFormat:@"%dm", (int)s.distance]];
    
    return header;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UMStation* station = stationManager.nearbyStations[indexPath.section];

    //Facility item
    if( indexPath.item < station.facilities.count) {

        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFacilityCellIdentifier forIndexPath:indexPath];
        
        UIButton* facilityButton = [cell viewWithTag:1];
        NSString * facility = [station.facilities[indexPath.item] allKeys][0];
        
        [facilityButton setTitle:facility forState:UIControlStateNormal];
        
        facilityButton.layer.borderWidth = 1.0;
        facilityButton.layer.borderColor = [UIColor colorWithRed:229.0f/255.0f green:71.0f/255.0f blue:55.0f/255.0f alpha:1.0].CGColor;
        
        return cell;
    }
    
    //Arrival item
    UMArrival* arrival = station.arrivals[indexPath.item - station.facilities.count];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kArrivalCellIdentifier forIndexPath:indexPath];
    
    UILabel* line = [cell viewWithTag:1];
    UILabel* direction = [cell viewWithTag:2];
    UILabel* tToArrival = [cell viewWithTag:3];
    
    line.text = arrival.lineName;
    direction.text = arrival.direction;
    tToArrival.text = [NSString stringWithFormat:@"%d:%d", (int)arrival.timeToStation / 60, (int)arrival.timeToStation % 60];
    
    return cell;
    
}


#pragma mark UICollectionViewDelegate

CGFloat const headerHeight = 40.0f;
CGFloat const facilityHeight = 30.0f;
CGFloat const arrivalHeight = 55.0f;
CGFloat const sectionInset = 10.0f;
CGFloat const facilityFontSize = 17.0f;

// Can only highlight facilities. No implemented functionality for taping on arrivals at the moment
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UMStation* station = stationManager.nearbyStations[indexPath.section];
    return indexPath.item < station.facilities.count;
    
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UMStation* station = stationManager.nearbyStations[indexPath.section];
    
    //Facility item
    if(indexPath.item < station.facilities.count) {
        
        //Compute required facility width based on text and font size
        NSString* facility = [station.facilities[indexPath.item] allKeys][0];
        CGRect labelRect = [facility boundingRectWithSize:CGSizeMake(999, headerHeight)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:facilityFontSize]}
                                                  context:nil];
        
        return CGSizeMake(labelRect.size.width + 3.0, labelRect.size.height); //Provide extra 3 pixels to exact size for breathable rects.
    }
    
    //Arrival item
    return CGSizeMake(collectionView.bounds.size.width - 2 * sectionInset, arrivalHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, sectionInset, 0, sectionInset);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, headerHeight);
}

#pragma mark UMStationManagerDelegate

- (void)stationManagerRefreshedStations:(id)manager {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView setAnimationsEnabled:NO];
        [self.collectionView reloadData];
        [UIView setAnimationsEnabled:YES];
    });
    
}

- (void)stationManager:(id)manager refreshedArrivalsForStation:(UMStation *)station {
    
    for (int i = 0; i < stationManager.nearbyStations.count; i++) {
        if (stationManager.nearbyStations[i] == station) {
            [UIView setAnimationsEnabled:NO];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:i]];
            [UIView setAnimationsEnabled:YES];
            break;
        }
    }
    
}

// Display standard alert controller when something went wrong
- (void)stationsManagerErrorRefreshing:(NSError*) error {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:true completion:NULL];
    });
    
}

//Whisper to user that he was detected outside of London
- (void)stationsManagerDetectedOutOfLondonLocation:(id)manager {
    
    [WhisperBridge whisperWithText:@"You are out of London. Using default location." textColor:[UIColor whiteColor] backgroundColor:[UIColor colorWithRed:229.0f/255.0f green:71.0f/255.0f blue:55.0f/255.0f alpha:1.0] toNavigationController:self.navigationController delay:5.0];
    
    
}

@end
