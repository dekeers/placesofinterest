//
//  GooglePlace.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

class GooglePlace {
    
    // MARK: - Properties
    
    var placeID = ""
    var name = ""
    var address = ""
    var website = ""
    var latitude = 0.0
    var longitude = 0.0
    
    // MARK: - Initializers    
    
    init() {}
    
    init(dictionary: [String:AnyObject]) {
        placeID = dictionary[GooglePlacesClient.JSONResponseKeys.PlaceID] as? String ?? ""
        name = dictionary[GooglePlacesClient.JSONResponseKeys.Name] as? String ?? ""
        website = dictionary[GooglePlacesClient.JSONResponseKeys.Website] as? String ?? ""
        address = dictionary[GooglePlacesClient.JSONResponseKeys.Address] as? String ?? ""
        
        if let geometry = dictionary[GooglePlacesClient.JSONResponseKeys.Geometry] as? [String:AnyObject], location = geometry[GooglePlacesClient.JSONResponseKeys.Location] as? [String:AnyObject] {
            latitude = location[GooglePlacesClient.JSONResponseKeys.Latitude] as? Double ?? 0.0
            longitude = location[GooglePlacesClient.JSONResponseKeys.Longitude] as? Double ?? 0.0
        }
    }
}
