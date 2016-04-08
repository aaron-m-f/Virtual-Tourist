//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var photo : Photo!
}
