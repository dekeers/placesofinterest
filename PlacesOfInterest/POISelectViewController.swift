//
//  POISelectViewController.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

class POISelectViewController: UIViewController {
    
    // MARK: - Properties
    
    let poiManager = POIManager.sharedInstance()
    @IBOutlet weak var poiCollectionView: UICollectionView!
    @IBOutlet weak var poiCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        poiCollectionView.dataSource = self
        poiCollectionView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
}

// MARK: - UICollectionViewDelegate

extension POISelectViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let activePOIIndex = poiManager.selectedPOITypeIndex {
            poiManager.setSelectedPOIType(POIManager.POIType(rawValue: indexPath.row)!)
            poiManager.deselectPOITypeIndex()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension POISelectViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return poiManager.poiDescriptions.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("POICollectionViewCell", forIndexPath: indexPath) as! POICollectionViewCell
        cell.poiImageView.image = UIImage(named: poiManager.poiImageNames[indexPath.row])
        cell.poiLabel.text = poiManager.poiDescriptions[indexPath.row]        
        return cell
    }
}
