//
//  FeaturedViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/9/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController {
    // Constants
    let CELL_ESTIMATED_WIDTH: CGFloat = 120.0
    let CELL_MARGIN: CGFloat = 10
    let CELL_RATIO: CGFloat = 1.5
    let CELL_LABEL_HEIGHT: CGFloat = 35
    
    // Properties
    var movies = [Movie]()
    var movieCount: Int = 0
    var totalPages: Int = 0
    var lastPageFetched: Int = 0
    var fetchingData: Bool = false

    var shouldTriggerSearch: Bool = false
    var searchController: UISearchController!
    var resultsTableController: GlobalSearchResultsController!
    
    // MARK: - Outlets
    @IBOutlet var loadingView: UIView!
    @IBOutlet var collectionView: UICollectionView!
}

// MARK: - Lifecycle
    
extension FeaturedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        // Get search results table controlleer
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsTableController = storyboard.instantiateViewController(withIdentifier: "resultsTableController") as! GlobalSearchResultsController

        // Setup search controller
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = resultsTableController

        searchController.searchBar.barStyle = .blackTranslucent
        searchController.searchBar.tintColor = UIColor.accent
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.transform = CGAffineTransform(translationX: 0, y: 5.0)

        searchController.dimsBackgroundDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        setupGrid()
        fetchMovies {
            self.loadingView.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDelegate Flow Layout

extension FeaturedViewController: UICollectionViewDelegateFlowLayout {
    func setupGrid() {
        let verticalMargin = CELL_MARGIN + 1
        let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: verticalMargin, left: CELL_MARGIN, bottom: verticalMargin, right: CELL_MARGIN)
        layout?.minimumLineSpacing = CELL_MARGIN
        layout?.minimumInteritemSpacing = CELL_MARGIN
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellCount = floor(self.view.frame.size.width / CELL_ESTIMATED_WIDTH)
        let cellWidth = floor((self.view.frame.size.width - (CELL_MARGIN * (cellCount + 1))) / cellCount)
        let cellHeight = (CELL_RATIO * cellWidth) + CELL_LABEL_HEIGHT
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - UICollectionView Data Source

extension FeaturedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(movieCount)
        return movieCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Expected MovieCollectionViewCell type for reuseIdentifier \(MovieCollectionViewCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        if indexPath.item < movies.count {
            cell.tag = movies[indexPath.item].id
            cell.set(movie: movies[indexPath.item])
        } else {
            cell.tag = 0
            cell.set(movie: nil)
            
            fetchMovies {
                guard indexPath.item < self.movies.count else { return }
                cell.tag = self.movies[indexPath.item].id
                cell.set(movie: self.movies[indexPath.item])
            }
        }
        
        return cell
    }
}

// MARK: - Data Prefetching

extension FeaturedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        fetchMovies()
    }
    
    func fetchMovies(with collection: MovieCollections = .NowPlaying, completionHandler: (() -> Void)? = nil) {
        guard fetchingData == false,
             (totalPages == 0 || lastPageFetched < totalPages)
        else { return }
        
        fetchingData = true
        lastPageFetched += 1
        
        switch collection {
        case .NowPlaying:
            Movie.nowPlaying(page: lastPageFetched) { (data, error, total) in
                DispatchQueue.main.async {
                    self.fetchMovieHelper(data: data, error: error, total: total)
                    completionHandler?()
                }
            }
        case .ComingSoon:
            Movie.comingSoon(page: lastPageFetched) { (data, error, total) in
                DispatchQueue.main.async {
                    self.fetchMovieHelper(data: data, error: error, total: total)
                    completionHandler?()
                }
            }
        }
    }
    
    func fetchMovieHelper(data: [Movie]?, error: Error?, total: (results: Int, pages: Int)?) {
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        
        guard let newMovies = data else {
            print("Error: unable to fetch movies")
            return
        }
        
        if let total = total, self.movieCount == 0 {
            self.movieCount = total.results
            self.totalPages = total.pages
        }

        self.movies.append(contentsOf: newMovies)

        self.fetchingData = false
        if self.lastPageFetched == 1 {
            self.collectionView?.reloadData()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.alpha = 1
            })
        }
    }
}

// MARK: - Segment Event

extension FeaturedViewController {
    @IBAction func featureChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView.alpha = 0
        }) { (success) in
            self.movies = [Movie]()
            self.lastPageFetched = 0
            self.fetchingData = false
            self.fetchMovies(with: MovieCollections(sender.selectedSegmentIndex))

            let offset = CGPoint(x: 0, y: -1 * self.view.safeAreaInsets.top)
            self.collectionView.setContentOffset(offset, animated: false)
        }
    }
    
    enum MovieCollections: Int {
        case NowPlaying = 0
        case ComingSoon
        
        init(_ value: Int) {
            switch value {
            case 1:
                self = .ComingSoon
            default:
                self = .NowPlaying
            }
        }
    }
}
// MARK: - Scroll View Delegate

extension FeaturedViewController {
    // Trigger search on pull down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if scrollOffset < -200 {
            shouldTriggerSearch = true
        }
    }

//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if shouldTriggerSearch {
//            searchController.searchBar.becomeFirstResponder()
//            shouldTriggerSearch = false
//        }
//    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if shouldTriggerSearch {
            searchController.searchBar.becomeFirstResponder()
            shouldTriggerSearch = false
        }
    }
}

// MARK: - Navigation

extension FeaturedViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < movies.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovie" {
            guard let movieDetailsVC = segue.destination as? MovieDetailViewController else { return }
            
            if let cell = sender as? MovieCollectionViewCell,
               let indexPath = self.collectionView?.indexPath(for: cell) {
                movieDetailsVC.movie = movies[indexPath.item]
                return
            }

            if let cell = sender as? MovieTableViewCell {
                movieDetailsVC.movie = cell.movie
                return
            }
        }
    }
}
