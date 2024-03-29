//
//  MovieDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import AVKit
import AVFoundation
import SafariServices
import UIKit
import WebKit

class MovieDetailViewController: UIViewController {
    // Constants
    let NUM_SECTIONS = 3
    let SECTION_HEADER = 0
    let SECTION_STAFF = 1
    let ROWS_HEADER = 2
    
    // Properties
    var movie: Movie?
    var populated: Bool = false
    var peekStatus: Bool = false
    var timer: Timer?
    var tintColor: UIColor?
    var tableHeaderFrame = CGRect()
    var shouldZoomPoster: Bool = false
    
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

        // Height: 425 (double) -> 385 (single)
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
        floatingBackButton.alpha = 0
        if wasPeeking != peekStatus {
            guard let movie = movie else { return }
            retrieveData(for: movie)
        }
        
        // Remove selection (if selection)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.floatingBackButton.alpha = 1
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Show the navigation bar when being dismissed
        if isMovingFromParent {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - View Methods

extension MovieDetailViewController {
    func setupView() {
        tintColor = UIColor.accent
        
        self.view.addGradientView(
            colors: [UIColor.bg, UIColor.clear],
            locations: [0.0, 0.3],
            view: self.tableView,
            frame: self.backgroundContainer.frame
        )
        
        // Setup table
        tableView.backgroundColor = UIColor.bg
        tableView.separatorColor = UIColor.separator
        tableView.showsVerticalScrollIndicator = false

        // Configure nav bar
        navigationItem.title = ""
        navBar.alpha = 0
        navItem.title = movie?.title
        
        // Setup activity indicators
        backgroundAI.startAnimating()
        posterAI.startAnimating()
        
        // Configure action buttons
        actionTrack.layer.cornerRadius = 9
        actionSeen.layer.cornerRadius = 9
    }
    
    func setupLoadingScreen() {
        if !populated {
            tableView.alpha = 0
            
            // Setup loading indicator
            loadingAI = UIActivityIndicatorView(style: .medium)
            loadingAI!.startAnimating()
            loadingAI!.center.x = view.center.x
            loadingAI!.center.y = view.center.y
            view.addSubview(loadingAI!)
            
            // Setup movie label
            loadingLabel = UILabel()
            loadingLabel?.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
            loadingLabel?.textColor = UIColor.white
            loadingLabel?.numberOfLines = 3
            loadingLabel?.textAlignment = .center
            
            loadingLabel!.text = movie?.title.uppercased()
            loadingLabel!.sizeToFit()
            
            view.addSubview(loadingLabel!)
            let margins = view.layoutMarginsGuide
            loadingLabel!.translatesAutoresizingMaskIntoConstraints = false
            loadingLabel!.topAnchor.constraint(equalTo: loadingAI!.bottomAnchor, constant: 8).isActive = true
            loadingLabel!.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
            loadingLabel!.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true

            let labelSize = loadingLabel!.sizeThatFits(CGSize(width: view.frame.width - 40, height: CGFloat.greatestFiniteMagnitude))
            loadingLabel?.heightAnchor.constraint(equalToConstant: labelSize.height).isActive = true
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

        if let date = movie.releaseDate?.toString() {
            if let duration = movie.duration {
                self.movieDescription.text = "\(date)  •  \(duration)"
            } else {
                self.movieDescription.text = "\(date)"
            }
        } else {
            self.movieDescription.text = nil
        }
        
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
                self.moviePoster.image = UIImage(color: UIColor.inactive)
            } else {
                self.moviePoster.image = poster
                self.shouldZoomPoster = true
            }
            
            self.moviePoster.layer.masksToBounds = true
            self.moviePoster.layer.cornerRadius = 5
            self.moviePoster.layer.borderWidth = 0.5
            self.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
            self.posterAI.stopAnimating()
            
            self.tintColor = poster?.averageColor ?? UIColor.accent
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
        self.tableView.reloadSections([SECTION_STAFF], with: .automatic)
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
        sender.isSelected = !sender.isSelected
        print("TEMP: \(movie?.title ?? "Unknown"): tracked = \(sender.isSelected)")
    }
    
    @IBAction func seenMovie(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        print("TEMP: \(movie?.title ?? "Unknown"): seen = \(sender.isSelected)")
        if sender.isSelected {
            actionTrack.alpha = 0.4
            actionTrack.isEnabled = false
        } else {
            actionTrack.alpha = 1.0
            actionTrack.isEnabled = true
        }
    }
    
    @IBAction func viewPoster(gestureRecognizer: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "showPoster", sender: self)
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
        return (section == SECTION_HEADER) ? 15 : 45.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_STAFF:
            return "Cast & Crew"
        case 2:   // TEMP: Trailer section
            return "Trailers"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_HEADER {
            return ROWS_HEADER
        } else if section == 2 {  // TEMP: Trailer section
            return movie?.trailers?.count ?? 0
        } else {
            return min(10, movie?.team.count ?? 0)
        }
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
        } else if indexPath.section == SECTION_STAFF {
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
            cell.setupCollection(movie: movie)
            return cell
        }
        // Overview cell
        else if indexPath == IndexPath(item: 1, section: SECTION_HEADER) {
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieOverviewCell.reuseIdentifier, for: indexPath) as! MovieOverviewCell
            cell.selectionStyle = .none
            cell.set(overview: movie?.overview)
            return cell
        }
        // Person cell
        else if indexPath.section == SECTION_STAFF {
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.reuseIdentifier, for: indexPath) as! PersonTableViewCell
            cell.tintColor = self.tintColor
            cell.selectionStyle = .default

            if let movie = movie, indexPath.item < movie.team.count {
                let person = movie.team[indexPath.item]
                cell.tag = person.id
                cell.set(person: person)
            }
            
            return cell
        }
        // TEMP: Trailer cell
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            let trailer = movie?.trailers?[indexPath.item]
            
            if let titleArr = trailer?.title.split(separator: "-"),
               let trailerTitle = titleArr.last
            {
                cell.textLabel?.text = String(trailerTitle).trimmingCharacters(in: .whitespaces)
            } else {
                cell.textLabel?.text = "Unknown \(trailer?.type.rawValue ?? "Trailer")"
            }
            
            cell.selectionStyle = .default
            
            return cell
        }
        // Detail cell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.selectionStyle = .default
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle overview text expansion
        if indexPath == IndexPath(item: 1, section: SECTION_HEADER) {
            if let cell = tableView.cellForRow(at: indexPath) as? MovieOverviewCell {
                cell.setSelected(false, animated: false)
                cell.overviewLabel.numberOfLines =
                    (cell.overviewLabel.numberOfLines == 0) ? 5 : 0
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        
        // TEMP: Load trailer
        if indexPath.section == 2 {
            if let videoURL = movie?.trailers?[indexPath.item].url {
//                let avPlayerVC = AVPlayerViewController()
//                print(videoURL)
//                avPlayerVC.player = AVPlayer(url: videoURL)
//
//                self.present(avPlayerVC, animated: true) {
//                    avPlayerVC.player?.play()
//                }

//                let webView = SFSafariViewController(url: videoURL)
//                self.present(webView, animated: true)
                
                let presentVC = UIViewController()
                let webView = WKWebView(frame: self.view.frame)
                webView.load(URLRequest(url: videoURL))
                presentVC.view.addSubview(webView)
                
                let dismissButton = UIButton(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 50))
                dismissButton.titleLabel?.text = "Dismiss"
                dismissButton.tintColor = UIColor.accent
                dismissButton.addTarget(self, action: #selector(dismissWebView), for: .touchDown)
                presentVC.view.insertSubview(dismissButton, aboveSubview: webView)
                
                self.present(presentVC, animated: true)
            }
        }
    }
    
    @objc func dismissWebView() {
        self.dismiss(animated: true)
    }
}

// MARK: - Navigation

extension MovieDetailViewController {
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showPoster" {
            // Only perform segue if there is a movie poster to display
            return self.shouldZoomPoster
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPerson" {
            guard let cell = sender as? PersonTableViewCell,
                  let personDetailsVC = segue.destination as? PersonDetailViewController
            else { return }

            personDetailsVC.tintColor = self.tintColor
            personDetailsVC.person = cell.person
        } else if segue.identifier == "showPoster" {
            guard let posterDetailsVC = segue.destination as? PosterDetailViewController else {
                return
            }
            posterDetailsVC.tintColor = self.tintColor
            posterDetailsVC.movie = self.movie
        }
    }
    
    @IBAction func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func navigateToRoot() {
        if let vcStack = self.navigationController?.viewControllers,
               vcStack.count > 1,
               vcStack[1] != self
        {
            self.navigationController?.popToViewController(vcStack[1], animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
