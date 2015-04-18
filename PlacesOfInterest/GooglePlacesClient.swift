//
//  GooglePlacesClient.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import MapKit
import Foundation

class GooglePlacesClient {
    
    // MARK: - Properties
    
    let session = NSURLSession.sharedSession()

    // MARK: - Client Convience Requests
    
    func getNearestPOI(location: CLLocation, type: String, completionHandler: (place: GooglePlace!, error: NSError!) -> Void) {    
        getNearestPlaceID(location, type: type) { (placeID, error) -> Void in
            if error == nil {
                self.getNearestPlace(placeID) { (place, error) -> Void in
                    if error == nil {
                        completionHandler(place: place, error: error)
                    } else {
                        completionHandler(place: nil, error: error)
                    }
                }
            } else {
                completionHandler(place: nil, error: error)
            }
        }
    }
    
    // MARK: - Client Requests
    
    private func getNearestPlaceID(location: CLLocation, type: String, completionHandler: (placeID: String!, error: NSError!) -> Void) {
        
        // build request
        let parameters = [
            ParameterKeys.Location: "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            ParameterKeys.Types: type,
            ParameterKeys.RankBy: Constants.RankingMethod,
            ParameterKeys.ApiKey: Constants.ApiKey
        ]
        let urlString = "\(Constants.BaseURL)\(Methods.NearbySearchJSON)" + GooglePlacesClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // make request
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error {
                completionHandler(placeID: "", error: error)
            } else {
                var parsingError: NSError? = nil
                let parsedData: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &parsingError) as! NSDictionary
                if parsingError == nil {
                    if let results = parsedData[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                        if results.count > 0 {
                            if let placeID = results[0][JSONResponseKeys.PlaceID] as? String {
                                completionHandler(placeID: placeID, error: nil)
                            } else {
                                completionHandler(placeID: "", error: NSError(domain: "GoogleClient.getNearestPlaceID(:) could not find key \(JSONResponseKeys.PlaceID) in \(results[0])", code: ErrorCodes.CouldNotFindKey, userInfo: nil))
                            }
                        } else {
                            completionHandler(placeID: "", error: NSError(domain: "GoogleClient.getNearestPlaceID(:) there are no nearby places", code: ErrorCodes.ZeroResults, userInfo: nil))
                        }
                    } else {
                        completionHandler(placeID: "", error: NSError(domain: "GoogleClient.getNearestPlaceID(:) could not find key \(JSONResponseKeys.Results) in \(parsedData)", code: ErrorCodes.CouldNotFindKey, userInfo: nil))
                    }
                } else {
                    completionHandler(placeID: "", error: parsingError)
                }
            }
        }
        
        // run request
        task.resume()
    }
    
    private func getNearestPlace(placeID: String, completionHandler: (place: GooglePlace!, error: NSError!) -> Void)  {
        
        // build request
        let parameters = [
            ParameterKeys.PlaceID: "\(placeID)",
            ParameterKeys.ApiKey: Constants.ApiKey
        ]
        let urlString = "\(Constants.BaseURL)\(Methods.DetailsJSON)" + GooglePlacesClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // make request
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error {
                completionHandler(place: nil, error: error)
            } else {
                var parsingError: NSError? = nil
                let parsedData = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &parsingError) as! NSDictionary
                if parsingError == nil {
                    if let results = parsedData[JSONResponseKeys.Result] as? [String:AnyObject] {
                        let place = GooglePlace(dictionary: results)
                        completionHandler(place: place, error: error)
                    } else {
                        completionHandler(place: nil, error: NSError(domain: "GoogleClient.getNearestPlace(:) could not find key \(JSONResponseKeys.Result) in \(parsedData)", code: ErrorCodes.CouldNotFindKey, userInfo: nil))
                    }
                } else {
                    completionHandler(place: nil, error: parsingError)
                }
            }
        }
        
        // run request
        task.resume()
    }

    // MARK: - Helpers
    
    // given a dictionary of parameters, convert to an escaped string
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            // make sure that it is a string value
            let stringValue = "\(value)"
            // escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            // append it
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> GooglePlacesClient {
        struct Singleton {
            static var sharedInstance = GooglePlacesClient()
        }
        return Singleton.sharedInstance
    }
}