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
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet var movieOverview: UILabel!
}

// MARK: - Lifecycle

extension MovieDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup view
        self.scrollView.contentInsetAdjustmentBehavior = .never

        self.movieTitle.text = movie?.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        if let date = movie?.releaseDate {
            let dateString = dateFormatter.string(from: date)
            self.movieDescription.text = "\(dateString)  •  2 hr 43 min"
        }
        
        self.movieOverview.text = movie?.overview
        
//        movie?.getDetails(completionHandler: { (movie, _) in
//            print(movie)
//        })

        movie?.getBackground(completionHandler: { (background, error) in
            self.backgroundImage.image = background
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        showNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        if scrollViewOffset < 0 {
            // TODO: resolve math for offset
            print(backgroundImageHeight)
            let translateOffset = -scrollViewOffset / 2
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, -scrollViewOffset / 2, 0)
            let scaleFactor: CGFloat = 1 + (-scrollViewOffset / backgroundImageHeight)
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            self.backgroundImage.layer.transform = transform
            print("offset: \(scrollViewOffset)\tscaleFactor: \(scaleFactor)")
            print("layer: \(self.backgroundImage.layer.frame)")
        } else {
            self.backgroundImage.layer.transform = CATransform3DIdentity
        }
        
        if scrollViewOffset > titleOffset {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
    
    func showNavigationBar() {
        if !navigationBarVisible {
            self.title = movie?.title
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationBarVisible = true
        }
    }
    
    func hideNavigationBar() {
        if navigationBarVisible {
            self.title = nil
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationBarVisible = false
        }
    }
}

// MARK: - Asset methods

extension MovieDetailViewController {
    func loadBackground() {
        guard let movie = movie else { return }
        
        if let posterURLString = movie.poster,
            let posterURL = URL(string: posterURLString)
        {
            URLSession.shared.dataTask(with: posterURL) { (data, response, error) in
                if let poster = data {
                    DispatchQueue.main.async {
                        self.backgroundImage.image = UIImage(data: poster)
                    }
                }
            }.resume()
        }
    }
}
