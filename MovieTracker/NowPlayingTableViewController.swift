//
//  NowPlayingTableViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

private let reuseIdentifier = "movieCell"

class NowPlayingTableViewController: UITableViewController {
    
    var movies: [DateComponents : [Movie]] = [:]
    var sections: [DateComponents] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Movie.nowShowing(page: 1, completionHandler: getMovies)
    }
    
    @IBAction func updateMovies(_ sender: UISegmentedControl) {
        updateMovies(index: sender.selectedSegmentIndex)
    }
    
    func updateMovies(index: Int) {
        switch index {
        case 0:
            Movie.nowShowing(page: 1, completionHandler: getMovies)
        case 1:
            Movie.comingSoon(page: 1, completionHandler: getMovies)
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies[sections[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections.count > 1 ? 45.0 : 0.01
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections.count <= 1 { return nil }
        
        let components = sections[section]
        guard let date = Calendar.current.date(from: components) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        return dateFormatter.string(from: date)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MovieTableViewCell
        guard let movie = movies[sections[indexPath.section]]?[indexPath.item] else {
            return cell
        }
        
        cell.movieTitle.text = movie.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.movieReleaseDate.text = dateFormatter.string(from: movie.releaseDate)
        
        cell.moviePoster.image = nil
        movie.getPoster { (poster, _) in
            cell.moviePoster.image = poster
            cell.moviePoster.layer.borderWidth = 0.5
            cell.moviePoster.layer.borderColor = UIColor(white: 0.15, alpha: 1).cgColor
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    // MARK: - Table Cell Actions
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let addAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Add") { (action, indexPath) in
            print(self.movies[self.sections[indexPath.section]]?[indexPath.item] ?? "Unknown movie")
        }
        
        addAction.backgroundColor = UIColor.gold

        actions.append(addAction)
        
        return actions
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            guard let movieDetailsVC = segue.destination as? MovieDetailViewController else { return }
            
            movieDetailsVC.movie = movies[self.sections[indexPath.section]]?[indexPath.item]
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
            self.movies = Dictionary(grouping: movies, by: { Calendar.current.dateComponents([.year, .month], from: $0.releaseDate) })
            self.sections = self.movies.keys.sorted { $0.year! > $1.year! || $0.month! > $1.month! }
            self.tableView.reloadData()
        }
    }
    
}
