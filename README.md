# UrbanMapper
iOS app that shows nearby tube stations with tube facility info and train arrival details.

## 1. Architecture

#### i. Model layer
**UMArrival** - Holds arrival information such as tToStation, direction, lineName.
**UMStation** - Holds necessary information of a station, including it's location, facilities and latest arrivals

#### ii. Network layer
**UMNetworkManager** - Abstracts the data feching process. Makes use of the Alamofire library. It's interface provides two static method calls. One to fech stations, and one to fetch arrivals for a station.

#### iii. Location layer
**UMLocationManager** - Handles requesting user's location and tracking. Also does a reverse geo-lookup to see wether or no the user's location is in London.

#### iv. Controller layer
**UMStationManager** - Connects Network/Data layer to the View layer. Provides **UMStationManagerDelegate** protocol to notify view of changes to the data. Also handles he timely refresh of arrival records.

#### v. View layer
**UMStationListVC** - A *UICollectionViewController* conforming to *UICollectionViewDelegateFlowLayout* to properly display both inline facilities as well as 'table-syle' arrival records.
**WhisperBridge** - A Swift bridge to connect the ObjC code with the *Whisper* library used to provide an elegant in-app user alert in case detected ouside of london.

## 2. Libraries 

- **[Alamofire](https://github.com/Alamofire/Alamofire)** - Alamofire is an HTTP networking library.
- **[Whisper](https://github.com/hyperoslo/Whisper)** - Whisper is a component simplifies the task of displaying messages and in-app notifications.

## 3. What's next?

A list of what would have been done granted more time was given. List is sorted by order in which they would have been done.

1. More complex UI design. Separate facilities from arrivals (unrelated).
2. Integrate Map and display nearby tubes using MapKit
3. Get much more data from [TfL's API](https://api-portal.tfl.gov.uk/docs) such as journey planning, status updates and information regarding other transport modes.
4. Integrate app with more capabilties. Today extention for nearby stations. Push (Alert and silent) notifications for user updates and silent background download tasks. Messaging extention to send location to friends. Siri integration to reques transit info home, or ETA for commuting home/work.
5. Social: Send location to friends while on trip so they can view ETA 
6. Bus stops. Show next bus arrivals at nearby stops.

**New**  features *not yet done*:
1. Integrate with payment platform (eg. Apple Pay) to allow users to replace Oyster Card. one time payments and monthly subscriptions through UrbanMapper.
2. Deep Linking. Allow developers to integrate a 1-tao buton to get any public transit info they need.
