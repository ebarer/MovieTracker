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
    
    func set(movie: Movie) {
        self.backgroundColor = UIColor.bg
        self.separatorInset = UIEdgeInsets(top: 0, left: 80.0, bottom: 0, right: 0)
        self.selectionColor = UIColor.selection
        
        self.movieTitle.text = movie.title
        
        let dateString = DateFormatter.detailPresentation.string(from: movie.releaseDate)
        self.movieReleaseDate.text = dateString
        
        self.moviePoster.image = nil
        
        self.moviePoster.image = nil
        self.moviePoster.alpha = 0
        self.moviePoster.layer.masksToBounds = true
        self.moviePoster.layer.cornerRadius = 5
        self.moviePoster.layer.borderWidth = 0.5
        self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        movie.getPoster { (poster, error, id) in
            guard let fetchID = id,
                  fetchID == movie.id
            else { return }
            
            if error != nil && poster == nil {
                print("Error: couldn't load poster for \(movie.title) - \(error!)")
                self.moviePoster.image = UIImage(color: UIColor.inactive)
            } else {
                self.moviePoster.image = poster
            }
            
            UIView.animate(withDuration: 0.5) {
                self.moviePoster.alpha = 1.0
            }
        }
        
    }
}
