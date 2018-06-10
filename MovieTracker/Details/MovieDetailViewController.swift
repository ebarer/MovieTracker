//
//  MovieDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, UIGestureRecognizerDelegate {
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
    @IBOutlet var actionBar: UIView!
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

        // Setup view
        self.scrollView.contentInsetAdjustmentBehavior = .never

        // Setup actions
        actionTrack.layer.cornerRadius = 15
        actionTrack.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        actionSeen.layer.cornerRadius = 15
        actionSeen.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        actionPlay.layer.cornerRadius = 25
        actionPlay.clipsToBounds = true
        actionTrailer.alpha = 0
        
        // Setup details
        self.movieTitle.text = movie?.title
        
        if let date = movie?.releaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let dateString = dateFormatter.string(from: date)
            self.movieDescription.text = "\(dateString)  •  2 hr 43 min"
        }
        
        self.movieOverview.text = movie?.overview
        
//        movie?.getDetails(completionHandler: { (movie, _) in
//            print(movie)
//        })
        
        // Setup artwork
        posterAI.startAnimating()
        backgroundAI.startAnimating()
        
        movie?.getPoster(completionHandler: { (poster, error) in
            self.moviePoster.image = poster
            self.moviePoster.layer.masksToBounds = true
            self.moviePoster.layer.cornerRadius = 5
            self.moviePoster.layer.borderWidth = 0.5
            self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
            self.posterAI.stopAnimating()
        })

        movie?.getBackground(completionHandler: { (background, error) in
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
    }
    
    @IBAction func seenMovie(_ sender: UIButton) {
        print("[Seen] \(movie?.title ?? "Unknown")")
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
