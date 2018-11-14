//
//  GlobalSearchResultsController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/13/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class GlobalSearchResultsController: UITableViewController {
    var movieResults = [Movie]()
    var peopleResults = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bg
    }
}

// MARK: - Navigation

extension GlobalSearchResultsController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovie" {
            guard let cell = sender as? MovieTableViewCell,
                let movie = cell.movie,
                let movieDetailsVC = segue.destination as? MovieDetailViewController
                else { return }
            movieDetailsVC.movie = movie
        } else if segue.identifier == "showPerson" {
            guard let cell = sender as? PersonTableViewCell,
                let person = cell.person,
                let personDetailsVC = segue.destination as? PersonDetailViewController
                else { return }
            personDetailsVC.person = person
        }
    }
}

// MARK: - Table view data source

extension GlobalSearchResultsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath)
        let movie = movieResults[indexPath.item]
        cell.tag = movie.id
        (cell as! MovieTableViewCell).set(movie: movie)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.presentingViewController as? FeaturedViewController,
           let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell
        {
            vc.performSegue(withIdentifier: "showMovie", sender: cell)
        }
    }

    func reloadData() {
        self.tableView.separatorStyle = (movieResults.count == 0) ? .none : .singleLine
        self.tableView.reloadData()
    }
}

// MARK: - Search helper methods

extension GlobalSearchResultsController {
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
                return "Search for movies"
            case .People:
                return "Search for cast and crew"
            }
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension GlobalSearchResultsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
            query.count > 0
            else {
                self.movieResults = []
                self.peopleResults = []
                self.reloadData()
                return
        }

        movieSearch(query: query)
    }
}
