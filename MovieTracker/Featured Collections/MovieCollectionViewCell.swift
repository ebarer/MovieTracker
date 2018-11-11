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
    func set(movie: Movie?) {
        self.movieTitle.text = movie?.title
        
        self.moviePoster.image = nil
        self.moviePoster.alpha = 0
        self.moviePoster.layer.masksToBounds = true
        self.moviePoster.layer.cornerRadius = 5
        self.moviePoster.layer.borderWidth = 0.5
        self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        movie?.getPoster(width: .w342) { (poster, error, id) in
            guard let movieID = movie?.id,
                  self.tag == movieID
            else {
                self.setImage(image: UIImage(color: UIColor.inactive))
                return
            }
            
            if error != nil && poster == nil {
                print("Error: couldn't load poster for \(movie?.title ?? "Unknown") - \(error!)")
                self.setImage(image: UIImage(color: UIColor.inactive))
            } else {
                self.setImage(image: poster)
            }
        }
    }
    
    func setImage(image: UIImage?) {
        self.moviePoster.image = image
        UIView.animate(withDuration: 0.5) {
            self.moviePoster.alpha = 1.0
        }
    }
}
