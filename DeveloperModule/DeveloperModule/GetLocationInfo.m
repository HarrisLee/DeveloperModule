//
//  GetLocationInfo.m
//  eCity
//
//  Created by NYZStar on 13-1-6.
//  Copyright (c) 2013年 q mm. All rights reserved.
//

#import "GetLocationInfo.h"

@implementation GetLocationInfo


- (id)init{
    self = [super init];
    if (self) {
        //定位相关
        _locationmanager = [[CLLocationManager alloc] init];
        _locationmanager.delegate = self;
        _locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationmanager.distanceFilter = 1000.0f;
        _locationcoder = [[CLGeocoder alloc] init];
//        [DataCenter shareInstance].localInfo = _locationmanager.location.coordinate;
    }
    return self;
}

-(void)StartLocation{
    [self.locationmanager startUpdatingLocation];
}

-(void)ShowLocationInfo:(NSArray *)placemarks{
    NSString *mesg = nil;
    MKPlacemark *citymark;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:[Utils getDstPlistPath:@"UserInfo"]];
    switch (placemarks.count) {
        case 0:
//            mesg = @"没有定位到当前城市";
            break;
        case 1:
            citymark = [placemarks objectAtIndex:0];
            if (citymark.locality && ![[dic objectForKey:@"city"] isEqualToString:citymark.locality]) {
                mesg = [NSString stringWithFormat:@"当前城市为:%@",citymark.locality];
                [dic setObject:citymark.locality forKey:@"city"];
                [dic writeToFile:[Utils getDstPlistPath:@"UserInfo"] atomically:YES];
            }
            else {
//                mesg = @"没有定位到当前城市";
            }
            [DataCenter shareInstance].city = [citymark.locality substringToIndex:[citymark.locality length]-1];
            break;
        default:
//            mesg = @"多个城市";
            break;
    }
    if (!locationAlert && !locationAlert.isVisible && mesg) {
        locationAlert = [[CAlertView alloc] initWithTitle:@"定位信息"
                                                   message:mesg
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
        [locationAlert show];
        [locationAlert release];
    }
    [dic release];
}

#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    if ( [error code] == kCLErrorDenied )
    {
        CAlertView *alert = [[CAlertView alloc] initWithTitle:@"定位服务已经关闭"
                                                        message:@"请您在设置页面中打开本软件的定位服务"
                                                        delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
    }
    else
    {
//        CAlertView *alert = [[CAlertView alloc] initWithTitle:@"定位失败！"
//                                                        message:@"请检查网络"
//                                                       delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
//    [self.locationcoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (error) {
//            CAlertView *alert = [[CAlertView alloc] initWithTitle:@"定位失败！"
//                                                            message:[NSString stringWithFormat:@"Reason:%@",error]
//                                                           delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
//            return ;
//        }
//        [self ShowLocationInfo:placemarks];
//    }];
//    MKReverseGeocoder *geocoder = [[[MKReverseGeocoder alloc]initWithCoordinate:newLocation.coordinate] autorelease];
//    geocoder.delegate = self;
//    //启动gecoder
//    [geocoder start];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    [self.locationcoder reverseGeocodeLocation:[locations objectAtIndex:0] completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (error) {
//            CAlertView *alert = [[CAlertView alloc] initWithTitle:@"定位失败！"
//                                                            message:[NSString stringWithFormat:@"Reason:%@",error]
//                                                           delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
//            return ;
//        }
//        [self ShowLocationInfo:placemarks];
//    }];
    CLLocation *location = [locations objectAtIndex:0];
    MKReverseGeocoder *geocoder = [[[MKReverseGeocoder alloc]initWithCoordinate:location.coordinate] autorelease];
    geocoder.delegate = self;
    //启动gecoder
    [geocoder start];
    [manager stopUpdatingLocation];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder
       didFindPlacemark:(MKPlacemark *)placemark
{
    [DataCenter shareInstance].localInfo  = geocoder.coordinate;
    [self ShowLocationInfo:[NSArray arrayWithObject:placemark]];
}

-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder
      didFailWithError:(NSError *)error
{
    CAlertView *alert = [[CAlertView alloc] initWithTitle:@"定位失败！"
                                                    message:@"请检查网络"
                                                   delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

-(void)dealloc{
    [_locationmanager release];
    _locationmanager = nil;
    [_locationcoder release];
    _locationcoder = nil;
    [super dealloc];
}

@end
