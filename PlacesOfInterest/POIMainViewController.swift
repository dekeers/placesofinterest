//
//  ViewController.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/16/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

class POIMainViewController: UIViewController {
    
    enum ViewMode {
        case Selecting, Editing
    }
    
    // MARK: - Properties     
    
    let poiManager = POIManager.sharedInstance()
    var viewMode = ViewMode.Selecting
    
    // MARK: - View Events   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editPOIButton = UIButton()
        editPOIButton.setImage(UIImage(named: "settings"), forState: .Normal)
        editPOIButton.addTarget(self, action: "setViewModeEditing", forControlEvents: .TouchUpInside)
        editPOIButton.frame = CGRectMake(0, 0, 30, 30)
        let editPOIBarButtonItem = UIBarButtonItem(customView: editPOIButton)
        self.navigationItem.rightBarButtonItem = editPOIBarButtonItem
        initPOIComponents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initPOIComponents()
    }
    
    // MARK: - UI
    
    func setViewModeEditing() {
        viewMode = .Editing
        startAnimatingPOIImages()
    }
    
    func initPOIComponents() {
        for index in 0...(poiImageViews.count-1) {
            let poi = poiManager.selectedPOITypes[index]
            poiLabels[index].text = poiManager.poiDescriptions[poi.rawValue]
            poiImageViews[index].image = UIImage(named: poiManager.poiImageNames[poi.rawValue])
        }
    }
    
    func startAnimatingPOIImages() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.toValue = 0.0
        shakeAnimation.fromValue = M_PI/16
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = Float.infinity
        shakeAnimation.autoreverses = true        
        for index in 0...(poiImageViews.count-1) {
            poiImageViews[index].layer.addAnimation(shakeAnimation, forKey: "shake")
        }
    }
    
    func stopAnimatingPOIImages() {
        for index in 0...(poiImageViews.count-1) {
            poiImageViews[index].layer.removeAnimationForKey("shake")
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func poiButtonSelected(sender: UIButton) {
        
        stopAnimatingPOIImages()
        
        if let buttonTitle = sender.currentTitle {
            poiManager.selectPOITypeIndex(buttonTitle.toInt()!)
            if poiManager.selectedPOITypes[buttonTitle.toInt()!] == POIManager.POIType.None || viewMode == .Editing {
                viewMode = .Selecting
                let poiSelectViewController = self.storyboard!.instantiateViewControllerWithIdentifier("POISelectViewController") as! POISelectViewController
                self.navigationController?.pushViewController(poiSelectViewController, animated: true)
            } else if viewMode == .Selecting {
                if poiManager.selectedPOITypes[buttonTitle.toInt()!] != .None {
                    let poiMapViewController = self.storyboard!.instantiateViewControllerWithIdentifier("POIMapViewController") as! POIMapViewController
                    self.navigationController?.pushViewController(poiMapViewController, animated: true)
                }
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var poiLabel1: UILabel!
    @IBOutlet weak var poiLabel2: UILabel!
    @IBOutlet weak var poiLabel3: UILabel!
    @IBOutlet weak var poiLabel4: UILabel!
    var poiLabels : [UILabel] { return [poiLabel1, poiLabel2, poiLabel3, poiLabel4] }

    @IBOutlet weak var poiImageView1: UIImageView!
    @IBOutlet weak var poiImageView2: UIImageView!
    @IBOutlet weak var poiImageView3: UIImageView!
    @IBOutlet weak var poiImageView4: UIImageView!
    var poiImageViews : [UIImageView] { return [poiImageView1, poiImageView2, poiImageView3, poiImageView4] }

    @IBOutlet weak var poiButton1: UIButton!
    @IBOutlet weak var poiButton2: UIButton!
    @IBOutlet weak var poiButton3: UIButton!
    @IBOutlet weak var poiButton4: UIButton!
    var poiButtons : [UIButton] { return [poiButton1, poiButton2, poiButton3, poiButton4] }
}