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
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBInspectable var selectionColor: UIColor = .gray {
        didSet {
            let view = UIView()
            view.backgroundColor = selectionColor
            selectedBackgroundView = view
        }
    }
}
