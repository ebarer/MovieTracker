//
//  MovieDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    // Constants
    let NUM_SECTIONS = 2
    let SECTION_HEADER = 0
    let SECTION_CAST = 1
    let ROWS_HEADER = 2
    
    // Properties
    var movie: Movie?
    var populated: Bool = false
    var peekStatus: Bool = false
    var timer: Timer?
    var tintColor: UIColor?
    var tableHeaderFrame = CGRect()
    var imageCache = NSCache<NSNumber, AnyObject>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Outlets

    @IBOutlet var floatingBackButton: UIButton!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navItem: UINavigationItem!
    
    var loadingAI: UIActivityIndicatorView?
    var loadingLabel: UILabel?
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
        retrieveData(for: movie)
        setupView()

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
        
        setupLoadingScreen()
        
        // Check if peeking, and hide floating back button
        let wasPeeking = peekStatus
        peekStatus = navigationController == nil
        floatingBackButton.isHidden = peekStatus
        if wasPeeking != peekStatus {
            guard let movie = movie else { return }
            retrieveData(for: movie)
        }
        
        // Remove selection (if selection)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
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
        tintColor = UIColor.inactive
        
        self.view.addGradientView(
            colors: [.bg, .clear],
            locations: [0.0, 0.3],
            view: self.tableView,
            frame: self.backgroundContainer.frame
        )
        
        // Setup table
        tableView.contentInsetAdjustmentBehavior = .never

        // Configure nav bar
        navBar.alpha = 0
        navItem.title = movie?.title
        navigationItem.title = movie?.title
        
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
    
    func setupLoadingScreen() {
        if !populated {
            tableView.alpha = 0
            
            // Setup loading indicator
            loadingAI = UIActivityIndicatorView(style: .whiteLarge)
            loadingAI!.startAnimating()
            loadingAI!.center.x = view.center.x
            loadingAI!.center.y = view.center.y - 40
            view.addSubview(loadingAI!)
            
            // Setup movie label
            loadingLabel = UILabel()
            loadingLabel?.font = UIFont.systemFont(ofSize: 33.0, weight: .bold)
            loadingLabel?.textColor = UIColor.white
            loadingLabel?.numberOfLines = 3
            loadingLabel?.textAlignment = .center
            
            
            loadingLabel!.text = movie?.title
            loadingLabel!.sizeToFit()
            
            view.addSubview(loadingLabel!)
            let margins = view.layoutMarginsGuide
            loadingLabel!.translatesAutoresizingMaskIntoConstraints = false
            loadingLabel!.topAnchor.constraint(equalTo: loadingAI!.bottomAnchor, constant: 20).isActive = true
            loadingLabel!.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
            loadingLabel!.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true

            let labelSize = loadingLabel!.sizeThatFits(CGSize(width: view.frame.width - 40, height: CGFloat.greatestFiniteMagnitude))
            loadingLabel?.heightAnchor.constraint(equalToConstant: labelSize.height)
        }
    }
    
    func retrieveData(for movie: Movie) {
        Movie.get(id: movie.id) { (movie, error) in
            guard error == nil, let movie = movie else {
                print("Error: \(error!)")
                return
            }
            
            DispatchQueue.main.async {
                print("Fetched: \(movie)")
                self.movie = movie
                self.populateData()
                self.getImages()
            }
        }
    }
    
    func populateData() {
        guard let movie = self.movie else { return }

        self.movieTitle.text = movie.title
        
        let dateString = DateFormatter.detailPresentation.string(from: movie.releaseDate)
        let duration = movie.duration ?? "Unknown"
        self.movieDescription.text = "\(dateString)  •  \(duration)"
        self.tableView.reloadData()
        
        if !populated {
            UIView.animate(withDuration: 0.5, animations: {
                self.loadingLabel?.alpha = 0
                self.loadingAI?.alpha = 0
            }) { (completion) in
                self.loadingAI?.stopAnimating()
                self.loadingAI?.removeFromSuperview()
                self.loadingLabel?.removeFromSuperview()
                UIView.animate(withDuration: 0.5, animations: {
                    self.tableView.alpha = 1
                })
            }
            
            populated = true
        }
    }
    
    func getImages() {
        guard let movie = movie else { return }
        
        movie.getPoster(width: .w342) { (poster, error, _) in
            if error != nil && poster == nil {
                print("Error: couldn't load poster - \(error!)")
                self.moviePoster.image = UIImage(color: UIColor.noImage)
            } else {
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
        self.navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : self.tintColor as Any]
        self.navBar.tintColor = self.tintColor
        self.tableView.tintColor = self.tintColor
        self.movieDescription.textColor = self.tintColor
        self.actionTrack.tintColor = self.tintColor
        self.actionSeen.tintColor = self.tintColor
        self.tableView.reloadSections([SECTION_CAST], with: .automatic)
    }
    
    @objc func imageTimeout() {
        timer?.invalidate()
        backgroundAI.stopAnimating()
        posterAI.stopAnimating()
    }
}

// MARK: - Navigation

extension MovieDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCast" {
            guard let cell = sender as? CastCell,
                  let castDetailsVC = segue.destination as? CastDetailViewController
            else { return }

            castDetailsVC.castMember = cell.castMember
        }
    }
}

// MARK: - Movie Actions

extension MovieDetailViewController {
    @IBAction func trackMovie(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        print("\(movie?.title ?? "Unknown"): tracked = \(sender.isSelected)")
    }
    
    @IBAction func seenMovie(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        print("\(movie?.title ?? "Unknown"): seen = \(sender.isSelected)")
        if sender.isSelected {
            actionTrack.alpha = 0.4
            actionTrack.isEnabled = false
        } else {
            actionTrack.alpha = 1.0
            actionTrack.isEnabled = true
        }
    }
    
    @IBAction func watchTrailer(_ sender: Any) {
        print("Play trailer: \(movie?.title ?? "Unknown")")
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
        return NUM_SECTIONS
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == SECTION_HEADER) ? 0.0 : 45.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_CAST:
            return "Cast & Crew"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == SECTION_HEADER) ? ROWS_HEADER : movie?.cast.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(indexPath: indexPath)
    }
    
    func heightForRow(indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 0, section: SECTION_HEADER) {
            return 100.0
        } else if indexPath.section == SECTION_CAST {
            return 65.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Scrollable cell
        if indexPath == IndexPath(item: 0, section: SECTION_HEADER) {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScrollableCell.reuseIdentifier, for: indexPath) as! ScrollableCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = .none
            cell.setupCollection(movie: movie!)
            return cell
        }
        // Overview cell
        else if indexPath == IndexPath(item: 1, section: SECTION_HEADER) {
            let cell = tableView.dequeueReusableCell(withIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = .none
            cell.set(overview: movie?.overview)
            return cell
        }
        // Detail cell
        else if indexPath.section == SECTION_CAST {
            let cell = tableView.dequeueReusableCell(withIdentifier: CastCell.reuseIdentifier, for: indexPath) as! CastCell
            cell.tintColor = self.tintColor
            cell.selectionStyle = .default
            
            if let movie = movie, indexPath.item < movie.cast.count {
                cell.set(castMember: movie.cast[indexPath.item], for: movie, with: imageCache)
            }
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.selectionStyle = .default
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle overview text expansion
        if indexPath == IndexPath(item: 1, section: SECTION_HEADER) {
            if let cell = tableView.cellForRow(at: indexPath) as? OverviewCell {
                cell.setSelected(false, animated: false)
                cell.overviewLabel.numberOfLines =
                    (cell.overviewLabel.numberOfLines == 0) ? 5 : 0
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
}
