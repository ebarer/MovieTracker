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
    let estimatedWidth: CGFloat = 120.0
    let cellMargin: CGFloat = 10
    let cellRatio: CGFloat = 1.5
    let cellLabel: CGFloat = 35
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Movie.nowShowing(page: 1, completionHandler: getMovies)
        setupGrid()
    }
    
    func setupGrid() {
        let verticalMargin = cellMargin + 1
        let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsetsMake(verticalMargin, cellMargin, verticalMargin, cellMargin)
        layout?.minimumLineSpacing = cellMargin
        layout?.minimumInteritemSpacing = cellMargin
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = dequeuedCell as? MovieCollectionViewCell else {
            return dequeuedCell
        }

        let movie = movies[indexPath.item]
        cell.movieTitle.text = movie.title
        
        cell.moviePoster.layer.masksToBounds = true
        cell.moviePoster.layer.cornerRadius = 5
        cell.moviePoster.layer.borderWidth = 1
        cell.moviePoster.layer.borderColor = UIColor(white: 0.15, alpha: 1).cgColor
        cell.activityIndicator.startAnimating()

        movie.getPoster(width: .w342) { (poster, error) in
            if error == nil {
                cell.moviePoster.image = poster
            } else {
                cell.moviePoster.image = nil
            }
            
            cell.activityIndicator.stopAnimating()
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
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
    
    // MARK: - Movie helper functions
    
    func getMovies(movies: [Movie]?, error: Error?) {
        guard let movies = movies else {
            return
        }
        
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        
        DispatchQueue.main.async {
            self.movies = movies
            self.collectionView?.reloadData()
        }
    }
}

extension NowPlayingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellCount = floor(self.view.frame.size.width / estimatedWidth)
        let cellWidth = (self.view.frame.size.width - (cellMargin * (cellCount + 1))) / cellCount
        let cellHeight = (cellRatio * cellWidth) + cellLabel
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
