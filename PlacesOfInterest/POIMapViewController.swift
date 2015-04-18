//
//  POIMapViewController.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import MapKit

class POIMapViewController: UIViewController {
    
    // MARK: - Properties
    
    let poiManager = POIManager.sharedInstance()
    var placeOfInterest: GooglePlace? = nil
    let mapPadding = 1.5
    let minimumVisibleLatitude = 0.01
    
    @IBOutlet weak var poiMapView: MKMapView!
    
    // MARK: - View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let openLocInAppleMapsButton = UIButton()
        openLocInAppleMapsButton.setImage(UIImage(named: "nav_arrow"), forState: .Normal)
        openLocInAppleMapsButton.addTarget(self, action: "openLocationInAppleMaps", forControlEvents: .TouchUpInside)
        openLocInAppleMapsButton.frame = CGRectMake(0, 0, 30, 30)
        let openLocInAppleMapsButtonBarButtonItem = UIBarButtonItem(customView: openLocInAppleMapsButton)
        self.navigationItem.rightBarButtonItem = openLocInAppleMapsButtonBarButtonItem
        
        poiMapView.delegate = self
        poiMapView.showsUserLocation = true
        
        if let lastKnownLocation = poiManager.lastKnownLocation {
            
            let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lastKnownLocation.coordinate.latitude, lastKnownLocation.coordinate.longitude), MKCoordinateSpanMake(0.2, 0.2))
            poiMapView.setRegion(region, animated: false)
            
            GooglePlacesClient.sharedInstance().getNearestPOI(lastKnownLocation, type: poiManager.selectedPOITypeDescription) { (place, error) -> Void in
                if error == nil {
                    if let place = place {
                        self.placeOfInterest = place
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.addAnnotationToMap(place)
                        })
                    } else {
                        println("oh no! there is no error, but there is also no place of interest!")
                    }
                } else {
                    if error.code == GooglePlacesClient.ErrorCodes.ZeroResults {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.showAlert("Sorry, we could not find a place of interest within \(GooglePlacesClient.Constants.MaxRadius) meters")
                        })
                        
                    } else {
                        println("\(error.debugDescription)")
                    }
                }
            }
        } else {
            println("oh no! last known location is empty!")
        }
    }
    
    // MARK: - Open Location
    
    func openLocationInAppleMaps() {
        if let placeOfInterest = placeOfInterest {
            let itemClass = MKMapItem.self
            if itemClass.respondsToSelector("openMapsWithItems:launchOptions:") {
                let destCoordinate = CLLocationCoordinate2D(latitude: placeOfInterest.latitude, longitude: placeOfInterest.longitude)
                let destEndLocation = MKPlacemark(coordinate: destCoordinate, addressDictionary: nil)
                let destination = MKMapItem(placemark: destEndLocation)
                destination.name = placeOfInterest.name
                let launchOptions = [MKLaunchOptionsDirectionsModeDriving: MKLaunchOptionsDirectionsModeKey]
                destination.openInMapsWithLaunchOptions(launchOptions)
            } else {
                if let googleMapsURL = NSURL(string: "comgooglemaps://?daddr=%\(placeOfInterest.address)&directionsmode=driving") {
                    UIApplication.sharedApplication().openURL(googleMapsURL)
                } else {
                    println("oh no! could not create google maps url")
                }
            }
        } else {
            showAlert("Sorry, we could not give directions since there is no place of interest within \(GooglePlacesClient.Constants.MaxRadius) meters")
        }
    }
    
    // MARK: - UI
    
    func addAnnotationToMap(place: GooglePlace) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        annotation.title = place.name
        annotation.subtitle = place.website
        poiMapView.addAnnotation(annotation)
        setMapRegionForAnnotation(annotation)
    }
    
    func setMapRegionForAnnotation(annotation: MKPointAnnotation) {
        let coordinatesOnMap = [annotation.coordinate, poiMapView.centerCoordinate]
        var minLatitude = CLLocationDegrees()
        var maxLatitude = CLLocationDegrees()
        var minLongitude = CLLocationDegrees()
        var maxLongitude = CLLocationDegrees()
        
        if coordinatesOnMap[0].latitude < coordinatesOnMap[1].latitude {
            minLatitude = coordinatesOnMap[0].latitude
            maxLatitude = coordinatesOnMap[1].latitude
        } else {
            minLatitude = coordinatesOnMap[1].latitude
            maxLatitude = coordinatesOnMap[0].latitude
        }
        if coordinatesOnMap[0].longitude < coordinatesOnMap[1].longitude {
            minLongitude = coordinatesOnMap[0].longitude
            maxLongitude = coordinatesOnMap[1].longitude
        } else {
            minLongitude = coordinatesOnMap[1].longitude
            maxLongitude = coordinatesOnMap[0].longitude
        }
        
        var region = MKCoordinateRegion()
        region.center.latitude = (minLatitude + maxLatitude) / 2
        region.center.longitude = (minLongitude + maxLongitude) / 2
        region.span.latitudeDelta = (maxLatitude - minLatitude) * mapPadding
        region.span.latitudeDelta = (region.span.latitudeDelta < minimumVisibleLatitude) ? minimumVisibleLatitude : region.span.latitudeDelta
        region.span.longitudeDelta = (maxLongitude - minLongitude) * mapPadding
        
        let scaledRegion = poiMapView.regionThatFits(region)
        poiMapView.setRegion(scaledRegion, animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - MKMapViewDelegate

extension POIMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        // do not re-annotate the center blue circle
        if annotation.isKindOfClass(MKUserLocation.self) { return nil }
        
        let reuseId = "PlacePin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            var canOpen = false
            
            if let canOpenURL = NSURL(string: annotationView.annotation.subtitle!) {
                canOpen = app.canOpenURL(canOpenURL)
            }
            
            if canOpen {
                app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
            } else {
                showAlert("Could not open website, invalid link")
            }
        }
    }
}
