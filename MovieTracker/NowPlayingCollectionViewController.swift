//
//  NowPlayingCollectionViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/3/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

private let reuseIdentifier = "movieCell"

class NowPlayingCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties

    var movies = [Movie]()
    var movieCount: Int = 0
    var totalPages: Int = 0
    var lastPageFetched: Int = 0
    var fetchingData: Bool = false
    
    let estimatedWidth: CGFloat = 120.0
    let cellMargin: CGFloat = 10
    let cellRatio: CGFloat = 1.5
    let cellLabel: CGFloat = 35
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGrid()
        fetchMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Expected MovieCollectionViewCell type for reuseIdentifier \(reuseIdentifier). Check the configuration in Main.storyboard.")
        }

        if indexPath.item < movies.count {
            cell.configure(with: movies[indexPath.item])
        } else {
            cell.configure(with: nil)

            fetchMovies {
                guard indexPath.item < self.movies.count else { return }
                
                cell.configure(with: self.movies[indexPath.item])
            }
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < movies.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let cell = sender as? UICollectionViewCell,
                  let indexPath = self.collectionView?.indexPath(for: cell),
                  let movieDetailsVC = segue.destination as? MovieDetailViewController
            else {
                return
            }
            
            movieDetailsVC.movie = movies[indexPath.item]
        }
    }
}

extension NowPlayingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func setupGrid() {
        let verticalMargin = cellMargin + 1
        let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: verticalMargin, left: cellMargin, bottom: verticalMargin, right: cellMargin)
        layout?.minimumLineSpacing = cellMargin
        layout?.minimumInteritemSpacing = cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellCount = floor(self.view.frame.size.width / estimatedWidth)
        let cellWidth = (self.view.frame.size.width - (cellMargin * (cellCount + 1))) / cellCount
        let cellHeight = (cellRatio * cellWidth) + cellLabel
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// Handle fetching data
extension NowPlayingCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        fetchMovies()
    }

    func fetchMovies(completionHandler: (() -> Void)? = nil) {
        if !fetchingData && (totalPages == 0 || lastPageFetched <= totalPages) {
            fetchingData = true
            lastPageFetched += 1
            print("Fetching page: \(lastPageFetched)")
            Movie.nowShowing(page: lastPageFetched) { (data, error, total) in
                guard let newMovies = data else {
                    print("Error: unable to fetch movies")
                    return
                }
                
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                
                DispatchQueue.main.async {
                    if let total = total, self.movieCount == 0 {
                        self.movieCount = total.results
                        self.totalPages = total.pages
                    }
                    
                    self.movies.append(contentsOf: newMovies)

                    self.fetchingData = false
                    
                    if self.lastPageFetched == 1 {
                        self.collectionView?.reloadData()
                    }

                    completionHandler?()
                }
            }
        }
    }
}
