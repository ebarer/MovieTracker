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
    
    // Configure cell
    func configure(with movie: Movie?) {
        self.movieTitle.text = movie?.title
        
        self.moviePoster.image = nil
        self.moviePoster.alpha = 0
        self.moviePoster.layer.masksToBounds = true
        self.moviePoster.layer.cornerRadius = 5
        self.moviePoster.layer.borderWidth = 1
        self.moviePoster.layer.borderColor = UIColor(white: 0.15, alpha: 1).cgColor
        self.activityIndicator.startAnimating()
        
        movie?.getPoster(width: .w342) { (poster, _) in
            self.activityIndicator.stopAnimating()
            self.moviePoster.image = poster
            UIView.animate(withDuration: 0.5) {
                self.moviePoster.alpha = 1.0
            }
        }
    }
    
}
