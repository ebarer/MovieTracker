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
    var tintColor: UIColor?
    var tableHeaderFrame = CGRect()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Outlets

    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navItem: UINavigationItem!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableHeader: UIView!
    
    @IBOutlet var backgroundContainer: UIView!
    @IBOutlet var backgroundAI: UIActivityIndicatorView!
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBOutlet var actionBar: UIView!
    @IBOutlet var actionTrack: UIButton!
    @IBOutlet var actionSeen: UIButton!
    
    @IBOutlet var posterContainer: UIView!
    @IBOutlet var posterAI: UIActivityIndicatorView!
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var actionPlay: UIView!
    @IBOutlet var actionPlayBlur: UIVisualEffectView!
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieDescription: UILabel!
}

// MARK: - Lifecycle

extension MovieDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movie = movie else { return }
        
        setupView()
        
        Movie.get(id: movie.id) { (movie, error) in
            guard error == nil, let movie = movie else {
                print("Error: \(error!)")
                return
            }
            
            DispatchQueue.main.async {
                self.movie = movie
                self.populateData()
                self.getImages()
            }
        }

        // Setup timer to hide activity indicators on failure
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(imageTimeout), userInfo: nil, repeats: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Height: 425 -> 385
        // Set the table header height for single line titles
        if movieTitle.frame.height < 79 &&
           tableHeader.frame.size.height != 385.0
        {
            tableHeader.frame.size.height = 385.0
            tableView.tableHeaderView = tableHeader
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide navigation stack navigation bar, replace with my own
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Show the navigation stack navigation bar for previous views in stack
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - View Methods

extension MovieDetailViewController {
    func setupView() {
        self.view.addGradientView(
            colors: [.bg, .clear],
            locations: [0.0, 0.3],
            view: self.tableView,
            frame: self.backgroundContainer.frame
        )
        
        // Setup table
        tintColor = UIColor.inactive
        tableView.contentInsetAdjustmentBehavior = .never

        // Configure nav bar
        navBar.alpha = 0
        navItem.title = movie?.title
        
        // Setup images
        actionPlayBlur.layer.cornerRadius = 30
        actionPlayBlur.clipsToBounds = true
        actionPlay.isHidden = true
        posterAI.startAnimating()
        backgroundAI.startAnimating()
        
        // Configure action buttons
        actionTrack.layer.cornerRadius = 9
        actionSeen.layer.cornerRadius = 9
    }
    
    func populateData() {
        guard let movie = self.movie else { return }

        self.movieTitle.text = movie.title
//        self.movieTitle.sizeToFit()
        
        let dateString = DateFormatter.detailPresentation.string(from: movie.releaseDate)
        let duration = movie.duration ?? "Unknown"
        self.movieDescription.text = "\(dateString)  •  \(duration)"
        self.tableView.reloadData()
    }
    
    func getImages() {
        guard let movie = movie else { return }
        
        movie.getPoster(width: .w342) { (poster, error, _) in
            if error != nil && poster == nil {
                print("Error: couldn't load poster - \(error!)")
                self.moviePoster.image = UIImage(color: UIColor.inactive)
            } else {
                print("\(movie.title): Retrieved poster")
                self.moviePoster.image = poster
            }
            
            self.moviePoster.layer.masksToBounds = true
            self.moviePoster.layer.cornerRadius = 5
            self.moviePoster.layer.borderWidth = 0.5
            self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
            self.posterAI.stopAnimating()
            self.actionPlay.isHidden = true
            
            self.tintColor = poster?.averageColor ?? UIColor.inactive
            self.tintView()
        }
        
        movie.getBackground() { (background, error, _) in
            guard error == nil, let background = background else {
                print("Error: couldn't load background image - \(error!)")
                self.backgroundAI.stopAnimating()
                return
            }
            
            print("\(movie.title): Retrieved background image")
            
            self.backgroundImage.image = background
            self.backgroundImage.alpha = 0
            
            self.backgroundImage.addGradient(
                colors: [.clear, .bg],
                locations: [0.6, 1.0]
            )
            
            self.backgroundAI.stopAnimating()
            UIView.animate(withDuration: 0.5) {
                self.backgroundImage.alpha = 1
            }
        }
    }
    
    func tintView() {
        self.tableView.tintColor = self.tintColor
        self.movieDescription.textColor = self.tintColor
        self.actionTrack.tintColor = self.tintColor
        self.actionSeen.tintColor = self.tintColor
        self.tableView.reloadSections([1], with: .automatic)
    }
    
    @objc func imageTimeout() {
        timer?.invalidate()
        backgroundAI.stopAnimating()
        posterAI.stopAnimating()
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
        if sender.isSelected {
            actionTrack.alpha = 0.4
            actionTrack.isEnabled = false
        } else {
            actionTrack.alpha = 1.0
            actionTrack.isEnabled = true
        }
    }
    
    @IBAction func watchTrailer(_ sender: Any) {
        print("Playing trailer: \(movie?.title ?? "Unknown")")
        
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
        let scrollOffset = scrollView.contentOffset.y
        let navBarOffset = view.safeAreaInsets.top + navBar.frame.height
        
        // Adjust height of background image based on offset
        let backgroundImageRatio: CGFloat = 3/4
        let backgroundImageHeight = backgroundImageRatio * scrollView.frame.width
        
        if scrollOffset < 0 {
            let translateOffset = scrollOffset
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, translateOffset / 2, 0)
            let scaleFactor: CGFloat = 1 + (-scrollOffset / backgroundImageHeight)
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            self.backgroundImage.layer.transform = transform
        } else {
            self.backgroundImage.layer.transform = CATransform3DIdentity
        }
        
        // Adjust title and navBar alphas based on offset
        let titleOffsetTop = movieTitle.frame.origin.y - navBarOffset
        let titleOffsetBottom = titleOffsetTop + (movieTitle.frame.height / 2)
        
        let alphaRatio = -1 / (titleOffsetBottom - titleOffsetTop)
        let alphaOffset = 1 - alphaRatio * titleOffsetTop
        let alpha = alphaRatio * scrollOffset + alphaOffset
        
        movieTitle.alpha = alpha
        navBar.alpha = 1 - alpha
        
        let transform = CATransform3DTranslate(CATransform3DIdentity, 2, 2, 0)
        self.tableHeader.layer.transform = transform
        
        // Make Action Bar sticky
        //        if tableHeaderFrame.origin.y == 0 {
        //            tableHeaderFrame = tableHeader.frame
        //        }
        //
        //        let tableHeaderOffset = actionBar.frame.origin.y - navBarOffset
        //        var translateY = scrollOffset - tableHeaderOffset
        //        translateY = translateY < 0 ? 0 : translateY
        //        tableHeader.frame = tableHeaderFrame.offsetBy(dx: 0, dy: translateY)
    }
}

// MARK: - Table View Data Source + Delegate

extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 0.0 : 25.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Cast & Crew"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 0, section: 0) {
            return 100.0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Scrollable cell
        if indexPath == IndexPath(item: 0, section: 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScrollableCell.reuseIdentifier, for: indexPath) as! ScrollableCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.setupCollection(movie: movie!)
            return cell
        }
        // Overview cell
        else if indexPath == IndexPath(item: 1, section: 0), let overview = movie?.overview {
            let cell = tableView.dequeueReusableCell(withIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.setOverview(overview)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(adjustOverview))
            cell.addGestureRecognizer(tapGesture)
            
            return cell
        }
        // Detail cell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.textLabel?.textColor = self.tintColor
            return cell
        }
    }
    
    @objc func adjustOverview(_ sender: Any) {
        let index = IndexPath(item: 1, section: 0)
        if let cell = tableView.cellForRow(at: index) as? OverviewCell {
            cell.overviewLabel.numberOfLines = 0
            UIView.animate(withDuration: 0.5) {
                cell.layoutIfNeeded()
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}
