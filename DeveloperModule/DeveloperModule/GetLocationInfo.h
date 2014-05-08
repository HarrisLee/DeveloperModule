//
//  GetLocationInfo.h
//  eCity
//
//  Created by NYZStar on 13-1-6.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <MapKit/MKReverseGeocoder.h>
#import <MapKit/MKPlacemark.h>

@interface GetLocationInfo : NSObject<CLLocationManagerDelegate,MKReverseGeocoderDelegate>{
    CLLocationManager * _locationmanager;
    CLGeocoder *_locationcoder;
    CAlertView     *locationAlert;
}
@property(nonatomic,retain)CLLocationManager * locationmanager;
@property(nonatomic,retain)CLGeocoder *locationcoder;

-(void)StartLocation;
-(void)ShowLocationInfo:(NSArray *)placemarks;

@end
