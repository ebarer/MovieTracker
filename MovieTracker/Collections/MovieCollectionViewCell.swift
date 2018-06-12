//
//  MovieCollectionViewCell.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/3/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "movieCollectionViewCell"
    
    // MARK: - Outlets
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var moviePoster: UIImageView!
}
    
// MARK: - Lifecycle

extension MovieCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
    
// MARK: - Configuration

extension MovieCollectionViewCell {
    func configure(with movie: Movie?) {
        self.movieTitle.text = movie?.title
        
        self.moviePoster.image = nil
        self.moviePoster.alpha = 0
        self.moviePoster.layer.masksToBounds = true
        self.moviePoster.layer.cornerRadius = 5
        self.moviePoster.layer.borderWidth = 0.5
        self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        movie?.getPoster(width: .w342) { (image, error) in
            guard error == nil, let poster = image else {
                print("Error: \(error!)")
                return
            }

            self.moviePoster.image = poster
            UIView.animate(withDuration: 0.5) {
                self.moviePoster.alpha = 1.0
            }
        }
    }
}