//
//  MovieDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    var id: Int?
    var movie: Movie?
    var navigationBarVisible: Bool = true
    
    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var backgroundAI: UIActivityIndicatorView!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var backgroundContainer: UIView!
    @IBOutlet var posterAI: UIActivityIndicatorView!
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var posterContainer: UIView!
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieDescription: UILabel!
    @IBOutlet var actionBar: UIStackView!
    @IBOutlet var actionTrack: UIButton!
    @IBOutlet var actionSeen: UIButton!
    @IBOutlet var actionTrailer: UIButton!
    @IBOutlet var actionPlay: UIVisualEffectView!
    @IBOutlet var movieOverview: UILabel!
}

// MARK: - Lifecycle

extension MovieDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movieID = id else { return }
        
        Movie.get(id: movieID) { (movie, error) in
            guard error == nil, let movie = movie else {
                return
            }
            
            DispatchQueue.main.async {
                self.movie = movie
                self.populateData()
            }
        }
    }
    
    func setupView() {
        self.scrollView.contentInsetAdjustmentBehavior = .never

        self.movieTitle.sizeToFit()
        
        // Configure action buttons
        actionTrack.layer.cornerRadius = 9
        actionSeen.layer.cornerRadius = 9
        actionTrailer.layer.cornerRadius = 9
        actionTrailer.alpha = 0
        
        // Setup images
        actionPlay.layer.cornerRadius = 25
        actionPlay.clipsToBounds = true
        posterAI.startAnimating()
        backgroundAI.startAnimating()
    }
    
    func populateData() {
        guard let movie = movie else { return }
        
        self.movieTitle.text = movie.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateString = dateFormatter.string(from: movie.releaseDate)
        if let duration = movie.duration {
            self.movieDescription.text = "\(dateString)  •  \(duration)"
        } else {
            self.movieDescription.text = "\(dateString)"
        }
        
        self.movieOverview.text = movie.overview
        
        movie.getPoster(completionHandler: { (poster, error) in
            self.moviePoster.image = poster
            self.moviePoster.layer.masksToBounds = true
            self.moviePoster.layer.cornerRadius = 9
            self.moviePoster.layer.borderWidth = 0.5
            self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
            self.posterAI.stopAnimating()
        })
        
        movie.getBackground(completionHandler: { (background, error) in
            self.backgroundImage.image = background
            self.backgroundImage.addGradient(
                colors: [.bg, .clear, .clear, .bg],
                locations: [0.0, 0.3, 0.6, 1.0]
            )
            self.backgroundAI.stopAnimating()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Movie Actions

extension MovieDetailViewController {
    @IBAction func trackMovie(_ sender: UIButton) {
        print("[Tracked] \(movie?.title ?? "Unknown")")
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? .gold : .inactive
    }
    
    @IBAction func seenMovie(_ sender: UIButton) {
        print("[Seen] \(movie?.title ?? "Unknown")")
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? .gold : .inactive
        actionTrack.isHidden = sender.isSelected
    }
    
    @IBAction func watchTrailer(_ sender: Any) {
        print("Playing trailer: \(movie?.title ?? "Unknown")")
    }
    
    func hideNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func showNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
}

// MARK: - Scroll View Delegate

extension MovieDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navBarHeight = view.safeAreaInsets.top
        let titleOffset = movieTitle.frame.origin.y - navBarHeight
        
        let scrollViewOffset = scrollView.contentOffset.y
        let backgroundImageRatio: CGFloat = 2/3
        let backgroundImageHeight = backgroundImageRatio * scrollView.frame.width
        
        print(scrollViewOffset)
        
        if scrollViewOffset < 0 {
            let translateOffset = scrollViewOffset
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, translateOffset / 2, 0)
            let scaleFactor: CGFloat = 1 + (-scrollViewOffset / backgroundImageHeight)
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            self.backgroundImage.layer.transform = transform
        } else {
            self.backgroundImage.layer.transform = CATransform3DIdentity
        }
        
        if scrollViewOffset > titleOffset {
            self.title = movie?.title
            showNavigationBar()
        } else {
            self.title = nil
            hideNavigationBar()
        }
    }
}
