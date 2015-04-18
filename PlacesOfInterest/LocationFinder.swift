//
//  LocationFinder.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import CoreLocation

class LocationFinder: NSObject {
    
    // MARK: - Properties
    
    let locationManager = CLLocationManager()
    var completionHandler : ((location: CLLocation?) -> Void)!
    var selfReference : LocationFinder? = nil

    // MARK: - Initializers
    
    init(completionHandler: (location: CLLocation?) -> Void) {
        super.init()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.completionHandler = completionHandler
        self.selfReference = self
    }
    
    // create a LocationFinder that calls completionHandler after didUpdateLocations
    class func getLocationFinderWithCompletionHandler(completionHandler: (location: CLLocation?) -> Void) {
        let locationFinder = LocationFinder(completionHandler: completionHandler)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationFinder: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let locationArray = locations as NSArray
        if let lastKnownLocation = locationArray.lastObject as? CLLocation {
            self.locationManager.stopUpdatingLocation()
            self.selfReference = nil
            self.completionHandler(location: lastKnownLocation)
        }
    }
}
