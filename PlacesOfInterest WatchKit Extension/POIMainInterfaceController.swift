//
//  POIMainInterfaceController.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/18/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import WatchKit
import Foundation

class POIMainInterfaceController: WKInterfaceController {
    
    // MARK: - Properties
    
    let poiManager = POIManager.sharedInstance()
    
    // MARK: - Interface Events
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        for index in 0...(poiImages.count-1) {
            let poi = poiManager.selectedPOITypes[index]
            poiImages[index].setImageNamed(poiManager.poiImageNames[poi.rawValue])
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func poiButton1Pressed() { pushMapPOIInterfaceControllerAtIndex(0) }
    @IBAction func poiButton2Pressed() { pushMapPOIInterfaceControllerAtIndex(1) }
    @IBAction func poiButton3Pressed() { pushMapPOIInterfaceControllerAtIndex(2) }
    @IBAction func poiButton4Pressed() { pushMapPOIInterfaceControllerAtIndex(3) }
    
    func pushMapPOIInterfaceControllerAtIndex(index: Int) {
        if poiManager.selectedPOITypes[index] != .None {
            pushControllerWithName("POIMapInterfaceController", context: poiManager.selectedPOITypes[index].rawValue)
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var poiImage1: WKInterfaceImage!
    @IBOutlet weak var poiImage2: WKInterfaceImage!
    @IBOutlet weak var poiImage3: WKInterfaceImage!
    @IBOutlet weak var poiImage4: WKInterfaceImage!
    var poiImages : [WKInterfaceImage] {
        get { return [poiImage1, poiImage2, poiImage3, poiImage4] }
    }
}
