//
//  MovieCollectionViewCell.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/3/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
