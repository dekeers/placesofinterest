//
//  GooglePlaceConstants.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

extension GooglePlacesClient {
    
    // MARK: - Constants
    
    struct Constants {
        static let ApiKey = "AIzaSyAxe7v4YhXtkUJ5lbMFWd5FYUcz7KWYQus"
        static let BaseURL = "https://maps.googleapis.com/maps/api/place/"
        static let MaxRadius = 50000 // in meters
        static let RankingMethod = "distance"
    }
    
    // MARK: - Methods
    
    struct Methods {    
        static let NearbySearchJSON = "nearbysearch/json"
        static let NearbySearchXML = "nearbysearch/xml"
        static let DetailsJSON = "details/json"
        static let DetailsXML = "details/xml"
    }
    
    // MARK: - ParameterKeys
    
    struct ParameterKeys {
        static let ApiKey = "key"
        static let PlaceID = "placeid"
        static let Location = "location"
        static let Types = "type"
        static let RankBy = "rankby"
    }
    
    // MARK: - JSONResponseKeys
    
    struct JSONResponseKeys {
        static let Result = "result"
        static let Results = "results"
        static let PlaceID = "place_id"
        static let Address = "formatted_address"
        static let Website = "website"
        static let Name = "name"
        static let Geometry = "geometry"
        static let Location = "location"
        static let Latitude = "lat"
        static let Longitude = "lng"
    }
    
    // MARK: - ErrorCodes
    
    struct ErrorCodes {
        static let ZeroResults = 0
        static let CouldNotFindKey = 1
    }
}
