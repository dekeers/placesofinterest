//
//  POICollectionViewCell.swift
//  PlacesOfInterest
//
//  Created by Jarrod Parkes on 4/17/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

class POICollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var poiImageView: UIImageView!
    @IBOutlet weak var poiLabel: UILabel!
    var poiCategory : String {
        get {
            return poiLabel.text!
        }
        set(newLabel) {
            poiLabel.text = newLabel
        }
    }
    var poiImage : UIImage {
        get {
            return poiImageView.image!
        }
        set(newImage) {
            poiImageView.image = newImage
        }
    }
}
