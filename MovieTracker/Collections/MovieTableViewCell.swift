//
//  MovieTableViewCell.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    static let reuseIdentifier = "movieCell"
    var movie: Movie?

    // MARK: - Outlets
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieReleaseDate: UILabel!
    @IBOutlet var moviePoster: UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup seperator inset = leftInset + picture + margin
        let leftInset = separatorInset.left + moviePoster.frame.width + 12
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        
        // Set selection color
        self.selectedBackgroundView = UIView(frame: self.frame)
        self.selectedBackgroundView!.backgroundColor = UIColor.selection
    }
    
    func set(movie: Movie) {
        self.movie = movie
        
        movieTitle.text = movie.title
        movieReleaseDate.text = movie.releaseDate?.toString() ?? "Unknown"
        
        moviePoster.image = nil
        moviePoster.alpha = 0
        moviePoster.layer.masksToBounds = true
        moviePoster.layer.cornerRadius = 5
        moviePoster.layer.borderWidth = 0.5
        moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        // TODO: Prevent timeout when searching
        // Log each outgoing call, ensure there
        // exists a corresponding inbound call
        movie.getPoster { (poster, error, id) in
            guard self.tag == movie.id else {
                self.setImage(image: UIImage(color: UIColor.inactive))
                return
            }
            
            if error != nil && poster == nil {
                print("Error: couldn't load poster for \(movie.title) - \(error!)")
                self.setImage(image: UIImage(color: UIColor.inactive))
            } else {
                self.setImage(image: poster)
            }
        }
    }
    
    func setImage(image: UIImage?) {
        self.moviePoster.image = image
        UIView.animate(withDuration: 0.5) {
            self.moviePoster.alpha = 1
        }
    }
}
