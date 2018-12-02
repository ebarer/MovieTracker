//
//  SearchTableViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/10/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    var movieResults = [Movie]()
    var peopleResults = [Person]()
    var scope: SearchScope = SearchScope.Movies
    let searchController = UISearchController(searchResultsController: nil)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bg

        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = scope.placeholder
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.searchBar.tintColor = UIColor.accent
        searchController.searchBar.keyboardAppearance = .dark
        
        // Setup search scope bar
        searchController.searchBar.scopeButtonTitles = SearchScope.titles
        searchController.searchBar.delegate = self
        
//        navigationItem.titleView = searchController.searchBar
        navigationItem.title = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Setup table
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Remove selection (if selection)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if noQuery() {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - Table view data source

extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch scope {
        case .Movies:
            return movieResults.count
        case .People:
            return peopleResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch scope {
        case .Movies:
            cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath)
            let movie = movieResults[indexPath.item]
            cell.tag = movie.id
            (cell as! MovieTableViewCell).set(movie: movie)
        case .People:
            cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.reuseIdentifier, for: indexPath)
            let person = peopleResults[indexPath.item]
            cell.tag = person.id
            (cell as! PersonTableViewCell).set(person: person)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch scope {
        case .Movies:
            return 95.0
        case .People:
            return 65.0
        }
    }
    
    func reloadData() {
        // Check if we have any results
        var results: Int
        switch scope {
        case .Movies:
            results = movieResults.count
        case .People:
            results = peopleResults.count
        }
        
        self.tableView.separatorStyle = (results == 0) ? .none : .singleLine
        self.tableView.reloadData()
    }
}

// MARK: - Search helper methods

extension SearchTableViewController {
    func movieSearch(query: String) {
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
                self.movieResults = newMovies
                self.reloadData()
            }
        }
    }
    
    func personSearch(query: String) {
        Person.search(query: query.lowercased(), page: 1) { (data, error, total) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            
            guard let people = data else {
                print("Error: unable to fetch movies")
                return
            }
            
            DispatchQueue.main.async {
                self.peopleResults = people
                self.reloadData()
            }
        }
    }
    
    func noQuery() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    enum SearchScope: Int {
        case Movies = 0
        case People
        
        init(value: Int) {
            switch value {
            case 1:
                self = .People
            default:
                self = .Movies
            }
        }
        
        static var titles: [String] {
            return ["Movies", "People"]
        }
        
        var placeholder: String {
            switch self {
            case .Movies:
                return "Enter movie title"
            case .People:
                return "Enter name of cast/crew"
            }
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              query.count > 0
        else {
            self.movieResults = []
            self.peopleResults = []
            self.reloadData()
            return
        }
        
        switch scope {
        case .Movies:
            movieSearch(query: query)
        case .People:
            personSearch(query: query)
        }
    }
}

// MARK: - UISearchBar Delegate

extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scope = SearchScope(value: selectedScope)
        searchBar.placeholder = scope.placeholder
        
        guard let query = searchBar.text,
              query.count > 0
        else {
            self.movieResults = []
            self.peopleResults = []
            self.reloadData()
            return
        }
        
        switch scope {
        case .Movies:
            movieSearch(query: query)
        case .People:
            personSearch(query: query)
        }
    }
}

// MARK: - Navigation

extension SearchTableViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovie" {
            guard let cell = sender as? MovieTableViewCell,
                let movie = cell.movie,
                let movieDetailsVC = segue.destination as? MovieDetailViewController
                else { return }
            movieDetailsVC.movie = movie
        }
        
        if segue.identifier == "showPerson" {
            guard let cell = sender as? PersonTableViewCell,
                let person = cell.person,
                let personDetailsVC = segue.destination as? PersonDetailViewController
                else { return }
            personDetailsVC.tintColor = UIColor.accent
            personDetailsVC.person = person
        }
    }
}
