//
//  POIMapInterfaceController.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/18/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import WatchKit
import Foundation

class POIMapInterfaceController: WKInterfaceController {
    
    // MARK: - Properties
    
    var poiType: POIManager.POIType? = nil
    var placeOfInterest: GooglePlace? = nil
    
    // MARK: - Interface Events
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        poiType = POIManager.POIType(rawValue: context as! Int)!
    }
    
    override func willActivate() {
        super.willActivate()
        getNearestPOIOnPhone()
    }
    
    // MARK: - Open Parent Application
    
    func getNearestPOIOnPhone() {
        var message = [
            POIManager.MessageKeys.CommandRequest: POIManager.Requests.GetNearestPOI,
            POIManager.MessageKeys.POIType: "\(poiType!.rawValue)"
        ]
        WKInterfaceController.openParentApplication(message) { (replyInfo, error) -> Void in
            if error == nil {
                self.handleParentApplicationCallback(replyInfo)
            } else {
                println(replyInfo!)
                println(error.debugDescription)
            }
        }
    }
    
    @IBAction func openLocationOnPhone() {
        if let placeOfInterest = placeOfInterest {
            var message = [
                POIManager.MessageKeys.CommandRequest: POIManager.Requests.OpenAppleMaps,
                POIManager.MessageKeys.Name: "\(placeOfInterest.name)",
                POIManager.MessageKeys.Latitude: "\(placeOfInterest.latitude)",
                POIManager.MessageKeys.Longitude: "\(placeOfInterest.longitude)",
                POIManager.MessageKeys.Address: "\(placeOfInterest.address)"
            ]
            WKInterfaceController.openParentApplication(message) { (replyInfo, error) -> Void in
                if error == nil {
                    self.handleParentApplicationCallback(replyInfo)
                } else {
                    println(replyInfo!)
                    println(error.debugDescription)
                }
            }
        }
    }
    
    // MARK: - Parent Application Callbacks
    
    func handleParentApplicationCallback(replyInfo: [NSObject : AnyObject]!) {
        let replyInfoDictionary = replyInfo as! [String:AnyObject]
        
        if let success = replyInfoDictionary[POIManager.MessageKeys.Success] as? Int where success == 1 {
            if let commandRequest = replyInfoDictionary[POIManager.MessageKeys.CommandRequest] as? String {
                switch commandRequest {
                case POIManager.Requests.OpenAppleMaps:
                    println("opening apple maps succeeded!")
                case POIManager.Requests.GetNearestPOI:
                    handleOpenMapsCallback(replyInfoDictionary)
                default:
                    println("unknown commandRequest")
                }
            }
        } else {
            println(replyInfoDictionary[POIManager.MessageKeys.Message] as? String)
        }
    }
    
    func handleOpenMapsCallback(replyInfoDictionary: [String:AnyObject]) {
        if let website = replyInfoDictionary[POIManager.MessageKeys.Website] as? String, name = replyInfoDictionary[POIManager.MessageKeys.Name] as? String, latitude = replyInfoDictionary[POIManager.MessageKeys.Latitude] as? Double, longitude = replyInfoDictionary[POIManager.MessageKeys.Longitude] as? Double, address = replyInfoDictionary[POIManager.MessageKeys.Address] as? String {
            
            placeOfInterest = GooglePlace()
            placeOfInterest!.name = name
            placeOfInterest!.latitude = latitude
            placeOfInterest!.longitude = longitude
            placeOfInterest!.website = website
            placeOfInterest!.address = address

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.nearestPOIMap.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)))
                self.nearestPOIMap.addAnnotation(center, withPinColor: .Red)
                self.nearestPOILabel.setText(name)
                self.openInAppleMapsButton.setEnabled(true)
            })
        } else {
            println("could not find keys '\(POIManager.MessageKeys.Name), \(POIManager.MessageKeys.Website), \(POIManager.MessageKeys.Latitude), \(POIManager.MessageKeys.Longitude), and \(POIManager.MessageKeys.Address)' in \(replyInfoDictionary)")
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nearestPOILabel: WKInterfaceLabel!
    @IBOutlet weak var nearestPOIMap: WKInterfaceMap!
    @IBOutlet weak var openInAppleMapsButton: WKInterfaceButton!
}