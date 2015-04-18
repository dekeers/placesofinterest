//
//  POIManager.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

 import MapKit
import Foundation

class POIManager {
    
    enum POIType: Int {
        case ATM = 0, Bakery, Bar, Cafe, Campground, Church, GasStation, Gym, HairCare, Hospital, Restaurant, ShoppingMall, None
    }
    
    // MARK: - Properties
    
    let userDefaultsWithAppGroup = NSUserDefaults(suiteName: "group.com.jarrodparkes.PlacesOfInterestAppGroup")
    let selectedPOITypesAsIntsKey = "selectedPOITypesAsInts"
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    let poiImageNames = ["atm", "bakery", "bar", "cafe", "campground", "church", "gas_station", "gym", "hair_care", "hospital", "restaurant", "shopping_mall", "question"]
    let poiDescriptions = ["ATM", "Bakery", "Bar", "Cafe", "Camp", "Church", "Gas", "Gym", "Hair", "Hospital", "Eat", "Shop", "Empty"]
    
    var selectedPOITypes = [POIType](count: 4, repeatedValue: .None)
    var selectedPOITypeIndex: Int? = nil
    var selectedPOITypeDescription: String {
        get {
            return poiImageNames[selectedPOITypes[selectedPOITypeIndex!].rawValue]
        }
    }
    var lastKnownLocation: CLLocation? = nil
    
    // MARK: - Initializers
    
    init() {
        if let userDefaultsWithAppGroup = userDefaultsWithAppGroup {
            if let selectedPOITypesAsInts = userDefaultsWithAppGroup.objectForKey(selectedPOITypesAsIntsKey) as? [Int] {
                selectedPOITypes = [
                    POIType(rawValue: selectedPOITypesAsInts[0])!,
                    POIType(rawValue: selectedPOITypesAsInts[1])!,
                    POIType(rawValue: selectedPOITypesAsInts[2])!,
                    POIType(rawValue: selectedPOITypesAsInts[3])!]
            }            
            lastKnownLocation = CLLocation(latitude: userDefaultsWithAppGroup.doubleForKey(latitudeKey), longitude: userDefaultsWithAppGroup.doubleForKey(longitudeKey))
            
            if Int(lastKnownLocation!.coordinate.latitude) == 0 && Int(lastKnownLocation!.coordinate.longitude) == 0 {
                grabAndSyncNewLocation()
            }
            
        } else {
            grabAndSyncNewLocation()
        }
    }
    
    // MARK: - Persistence
    
    func syncSelectedPOITypes() {
        if let userDefaultsWithAppGroup = userDefaultsWithAppGroup {
            let selectedPOITypesAsInts = [
                selectedPOITypes[0].rawValue,
                selectedPOITypes[1].rawValue,
                selectedPOITypes[2].rawValue,
                selectedPOITypes[3].rawValue
            ]
            userDefaultsWithAppGroup.setObject(selectedPOITypesAsInts, forKey: selectedPOITypesAsIntsKey)
            userDefaultsWithAppGroup.synchronize()
        }
    }
    
    func grabAndSyncNewLocation() {
        LocationFinder.getLocationFinderWithCompletionHandler() { (location) -> Void in
            if let location = location {
                if let userDefaultsWithAppGroup = self.userDefaultsWithAppGroup {
                    userDefaultsWithAppGroup.setDouble(location.coordinate.latitude, forKey: self.latitudeKey)
                    userDefaultsWithAppGroup.setDouble(location.coordinate.longitude, forKey: self.longitudeKey)
                    userDefaultsWithAppGroup.synchronize()
                }
                self.lastKnownLocation = location
            }
        }
    }
    
    // MARK: - POI Management
    
    func selectPOITypeIndex(index: Int) { selectedPOITypeIndex = index }
    func deselectPOITypeIndex() { selectedPOITypeIndex = nil }
    func setSelectedPOIType(poiType: POIType) {
        if let selectedPOITypeIndex = selectedPOITypeIndex {
            selectedPOITypes[selectedPOITypeIndex] = poiType
            syncSelectedPOITypes()
        }
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> POIManager {
        struct Singleton {
            static var sharedInstance = POIManager()
        }
        return Singleton.sharedInstance
    }
}
