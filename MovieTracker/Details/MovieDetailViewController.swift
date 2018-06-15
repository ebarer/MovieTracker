//
//  MovieDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    var movie: Movie?
    var timer: Timer?
    var actionBarFrame = CGRect()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Outlets

    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navItem: UINavigationItem!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var backgroundContainer: UIView!
    @IBOutlet var backgroundAI: UIActivityIndicatorView!
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBOutlet var posterContainer: UIView!
    @IBOutlet var posterAI: UIActivityIndicatorView!
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var actionPlay: UIView!
    @IBOutlet var actionPlayBlur: UIVisualEffectView!
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieDescription: UILabel!
    
    @IBOutlet var actionBar: UIView!
    @IBOutlet var actionTrack: UIButton!
    @IBOutlet var actionSeen: UIButton!
    
    @IBOutlet var movieOverview: UILabel!
    
    @IBOutlet var detailMask: UIView!
    @IBOutlet var detailTable: UITableView!
}

// MARK: - Lifecycle

extension MovieDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movie = movie else { return }
        
        setupView()
        populateData()
        
        Movie.get(id: movie.id) { (movie, error) in
            guard error == nil, let movie = movie else {
                print("Error: \(error!)")
                return
            }
            
            DispatchQueue.main.async {
                self.movie = movie
                self.populateData()
            }
        }

        // Setup timer to hide activity indicators on failure
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(imageTimeout), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//        self.transitionCoordinator?.animate(alongsideTransition: { (tcc) in
//            self.navigationController?.navigationBar.alpha = 0
//        }, completion: nil)
    }
    
    @IBAction func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - View Methods

extension MovieDetailViewController {
    func setupView() {
        // Configure scroll view
        scrollView.contentInsetAdjustmentBehavior = .never
        
        // Configure nav bar
        navBar.alpha = 0
        navItem.title = movie?.title
        
        // Setup images
        actionPlayBlur.layer.cornerRadius = 25
        actionPlayBlur.clipsToBounds = true
        actionPlay.isHidden = true
        posterAI.startAnimating()
        backgroundAI.startAnimating()
        
        // Configure action buttons
        actionTrack.layer.cornerRadius = 9
        actionSeen.layer.cornerRadius = 9
    }
    
    func populateData() {
        guard let movie = movie else { return }
        
        self.movieTitle.text = movie.title
        self.movieTitle.sizeToFit()
        
        let dateString = DateFormatter.detailPresentation.string(from: movie.releaseDate)
        if let duration = movie.duration {
            self.movieDescription.text = "\(dateString)  •  \(duration)"
        } else {
            self.movieDescription.text = "\(dateString)"
        }
        
        // Ensure movie details have been fetched
        guard let overview = movie.overview else { return }
        self.movieOverview.text = overview
        self.detailTable.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.detailMask.alpha = 0
        }) { (_) in
            self.detailMask.isHidden = true
        }
        
        movie.getPoster(width: .w342) { (poster, error, _) in
            self.moviePoster.image = poster
            self.moviePoster.layer.masksToBounds = true
            self.moviePoster.layer.cornerRadius = 9
            self.moviePoster.layer.borderWidth = 0.5
            self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
            self.posterAI.stopAnimating()
            self.actionPlay.isHidden = false
        }
        
        movie.getBackground() { (background, error, _) in
            self.backgroundImage.image = background
            self.backgroundImage.alpha = 0
            self.backgroundImage.addGradient(
                colors: [.bg, .clear, .clear, .bg],
                locations: [0.0, 0.3, 0.6, 1.0]
            )
            
            self.backgroundAI.stopAnimating()
            UIView.animate(withDuration: 0.5) {
                self.backgroundImage.alpha = 1
            }
        }
    }
    
    @objc func imageTimeout() {
        timer?.invalidate()
        backgroundAI.stopAnimating()
        posterAI.stopAnimating()
    }
    
    func adjustOverview() {
        movieOverview.numberOfLines = (movieOverview.numberOfLines == 0) ? 5 : 0
        UIView.animate(withDuration: 0.5) {
            self.movieOverview.superview?.layoutIfNeeded()
        }
    }
}

// MARK: - Movie Actions

extension MovieDetailViewController {
    @IBAction func trackMovie(_ sender: UIButton) {
        print("[Tracked] \(movie?.title ?? "Unknown")")
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func seenMovie(_ sender: UIButton) {
        print("[Seen] \(movie?.title ?? "Unknown")")
        sender.isSelected = !sender.isSelected
        actionTrack.isHidden = sender.isSelected
    }
    
    @IBAction func watchTrailer(_ sender: Any) {
        print("Playing trailer: \(movie?.title ?? "Unknown")")
        adjustOverview()
    }
}

// MARK: - UINavigationBar Delegates

extension MovieDetailViewController: UINavigationBarDelegate, UIGestureRecognizerDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Scroll View Delegate

extension MovieDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewOffset = scrollView.contentOffset.y
        let navBarOffset = view.safeAreaInsets.top + navBar.frame.height
        
        // Adjust height of background image based on offset
        let backgroundImageRatio: CGFloat = 3/4
        let backgroundImageHeight = backgroundImageRatio * scrollView.frame.width
        
        if scrollViewOffset < 0 {
            let translateOffset = scrollViewOffset
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, translateOffset / 2, 0)
            let scaleFactor: CGFloat = 1 + (-scrollViewOffset / backgroundImageHeight)
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            self.backgroundImage.layer.transform = transform
        } else {
            self.backgroundImage.layer.transform = CATransform3DIdentity
        }
        
        // Adjust title and navBar alphas based on offset
        let titleOffsetTop = movieTitle.frame.origin.y - navBarOffset
        let titleOffsetBottom = titleOffsetTop + (movieTitle.frame.height / 2)
        
        let ratio = -1 / (titleOffsetBottom - titleOffsetTop)
        let offset = 1 - ratio * titleOffsetTop
        let alpha = ratio * scrollViewOffset + offset
        
        movieTitle.alpha = alpha
        navBar.alpha = 1 - alpha
        
        // Make Action Bar sticky
        if actionBarFrame.origin.y == 0 {
            actionBarFrame = actionBar.frame
        }

        let actionBarOffset = actionBarFrame.origin.y - navBarOffset
        let translateY: CGFloat = scrollViewOffset - actionBarOffset
        if translateY > 0 {
            actionBar.frame = actionBarFrame.offsetBy(dx: 0, dy: translateY)
        }
    }
}

// MARK: - Table View Delegate

extension MovieDetailViewController: UITableViewDelegate {
    
}

// MARK: - Table View Data Source

extension MovieDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Certification"
            cell.detailTextLabel?.text = movie?.certification ?? "Unavailable"
        case 1:
            cell.textLabel?.text = "Genres"
            cell.detailTextLabel?.text = movie?.genres?.joined(separator: ", ") ?? "N/A"
        case 2:
            cell.textLabel?.text = "Rating"
            cell.detailTextLabel?.text = "N/A"
            if let rating = movie?.rating, rating > 0 {
                cell.detailTextLabel?.text = String(format: "%.1f / 5", rating / 2)
            }
        default:
            break
        }
        
        return cell
    }
}
