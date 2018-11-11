//
//  SearchTableViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/10/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    var searchResults = [Movie]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.bg

        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.searchBar.tintColor = UIColor.accent
        searchController.searchBar.keyboardAppearance = .dark
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

//        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchBar.setShowsCancelButton(false, animated: false)
        navigationItem.titleView = searchController.searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if noQuery() {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
    }
    
    func noQuery() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func reloadData() {
        // Check if we have any results
        self.tableView.separatorStyle = (searchResults.count == 0) ? .none : .singleLine
        self.tableView.reloadData()
    }
}

// MARK: - Navigation

extension SearchTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            guard let movieDetailsVC = segue.destination as? MovieDetailViewController else { return }
            
            movieDetailsVC.movie = searchResults[indexPath.item]
        }
    }
}

// MARK: - Table view data source

extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
        
        let movie = searchResults[indexPath.item]
        cell.set(movie: movie)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let query = searchController.searchBar.text {
            guard query.count > 0 else {
                self.searchResults = []
                self.reloadData()
                return
            }
            
            Movie.search(query: query.lowercased(), page: 1) { (data, error, total) in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                
                guard let newMovies = data else {
                    print("Error: unable to fetch movies")
                    return
                }
                
                DispatchQueue.main.async {
                    self.searchResults = newMovies
                    self.reloadData()
                }
            }
        }
    }
}
