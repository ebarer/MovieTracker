//
//  MovieTableViewCell.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieReleaseDate: UILabel!
    @IBOutlet var moviePoster: UIImageView!
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
