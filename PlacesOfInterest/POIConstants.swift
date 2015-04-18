//
//  POIConstants.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/18/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

extension POIManager {
    
    // MARK: - MessageKeys
    
    struct MessageKeys {
        static let CommandRequest = "commandRequest"
        static let Name = "name"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Success = "success"
        static let Message = "message"
        static let Address = "address"
        static let Website = "website"
        static let POIType = "poiType"
    }
    
    // MARK: - Requests
    
    struct Requests {
        static let OpenAppleMaps = "openMaps"
        static let GetNearestPOI = "getNearestPOI"
    }
    
    
}
