//
//  AppDelegate.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/16/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        if let userInfoDictionary = userInfo as? [String:AnyObject] {
            if let commandRequest = userInfoDictionary[POIManager.MessageKeys.CommandRequest] as? String {
                switch commandRequest {
                case POIManager.Requests.OpenAppleMaps:
                    handleOpenMapsRequest(userInfoDictionary, reply: reply)
                case POIManager.Requests.GetNearestPOI:
                    handleGetNearestPOIRequest(userInfoDictionary, reply: reply)
                default:
                    reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "handler for \(commandRequest) not found"])
                }
            } else {
                reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "could not find key '\(POIManager.MessageKeys.CommandRequest)' in \(userInfoDictionary)"])
            }
        } else {
            reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "could not cast \(userInfo) as [String:AnyObject]"])
        }
    }
    
    func handleOpenMapsRequest(userInfoDictionary: [String:AnyObject],reply: (([NSObject : AnyObject]!) -> Void)!) {
        if let name = userInfoDictionary[POIManager.MessageKeys.Name] as? String, latitudeString = userInfoDictionary[POIManager.MessageKeys.Latitude] as? String, longitudeString = userInfoDictionary[POIManager.MessageKeys.Longitude] as? String, address = userInfoDictionary[POIManager.MessageKeys.Address] as? String {
                let itemClass = MKMapItem.self
                if itemClass.respondsToSelector("openMapsWithItems:launchOptions:") {
                    let latitude = (latitudeString as NSString).doubleValue
                    let longitude = (longitudeString as NSString).doubleValue
                    let destCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let destEndLocation = MKPlacemark(coordinate: destCoordinate, addressDictionary: nil)
                    let destination = MKMapItem(placemark: destEndLocation)
                    destination.name = name
                    let launchOptions = [MKLaunchOptionsDirectionsModeDriving: MKLaunchOptionsDirectionsModeKey]
                    destination.openInMapsWithLaunchOptions(launchOptions)
                } else {
                    if let googleMapsURL = NSURL(string: "comgooglemaps://?daddr=%\(address)&directionsmode=driving") {
                        UIApplication.sharedApplication().openURL(googleMapsURL)
                    } else {
                        reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "oh no! could not create google maps url"])
                    }
                }
                reply([POIManager.MessageKeys.Success: true, POIManager.MessageKeys.CommandRequest: POIManager.Requests.OpenAppleMaps, POIManager.MessageKeys.Message: "poi opened in apple maps!"])
        } else {
            reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "could not find keys '\(POIManager.MessageKeys.Name), \(POIManager.MessageKeys.Latitude), \(POIManager.MessageKeys.Longitude), and \(POIManager.MessageKeys.Address)' in \(userInfoDictionary)"])
        }
    }
    
    func handleGetNearestPOIRequest(userInfoDictionary: [String:AnyObject], reply: (([NSObject : AnyObject]!) -> Void)!) {
        if let poiType = userInfoDictionary[POIManager.MessageKeys.POIType] as? String {
            let poiManager = POIManager.sharedInstance()            
            if let lastKnownLocation = poiManager.lastKnownLocation {
                GooglePlacesClient.sharedInstance().getNearestPOI(lastKnownLocation, type: poiManager.poiImageNames[poiType.toInt()!]) { (place, error) -> Void in
                    if error == nil {
                        reply([
                            POIManager.MessageKeys.Success: true,
                            POIManager.MessageKeys.CommandRequest: POIManager.Requests.GetNearestPOI,
                            POIManager.MessageKeys.Name: place.name,
                            POIManager.MessageKeys.Latitude: place.latitude,
                            POIManager.MessageKeys.Longitude: place.longitude,
                            POIManager.MessageKeys.Website: place.website,
                            POIManager.MessageKeys.Address: place.address
                        ])
                    } else {
                        reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: error.description])
                    }
                }
            } else {
              reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "last known location is empty!"])
            }
        } else {
            reply([POIManager.MessageKeys.Success: false, POIManager.MessageKeys.Message: "invalid poi type!"])
        }
    }
}