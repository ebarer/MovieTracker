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
        
        Movie.comingSoon(page: 1) { (data, error, _) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            
            guard let newMovies = data else {
                print("Error: unable to fetch movies")
                return
            }
            
            // Split data into dictionary and sort
            var movieDict = Dictionary(grouping: newMovies, by: { Calendar.current.dateComponents([.year, .month], from: $0.releaseDate) })
            let months = movieDict.keys.sorted { (a, b) -> Bool in
                return a.year! > b.year! ? false : a.month! < b.month!
            }
            
            for key in months {
                movieDict[key]?.sort { $0.releaseDate.compare($1.releaseDate) == .orderedAscending }
            }
            
            DispatchQueue.main.async {
                self.movies = movieDict
                self.sections = months
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func updateMovies(_ sender: UISegmentedControl) {
        print("Segment controller clicked")
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
        return sections.count > 1 ? 55.0 : 0.01
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections.count <= 1 { return nil }
        
        let components = sections[section]
        guard let date = Calendar.current.date(from: components) else {
            return nil
        }
        
        return DateFormatter.sectionHeader.string(from: date)
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

        let dateString = DateFormatter.detailPresentation.string(from: movie.releaseDate)
        cell.movieReleaseDate.text = dateString
        
        cell.moviePoster.image = nil
        movie.getPoster { (poster, _, id) in
            guard movie.id == id else {
                return
            }
            
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
        
        let addAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "Add") { (action, indexPath) in
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
    
}
