//
//  NowPlayingTableViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class NowPlayingTableViewController: UITableViewController {
    
    var movies: [DateComponents : [Movie]] = [:]
    var sections: [DateComponents] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.bg
        navigationController?.navigationBar.shadowImage = UIImage()
        
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
            var movieDict = Dictionary(grouping: newMovies, by: { (movie) -> DateComponents in
                guard let releaseDate = movie.releaseDate else {
                    // TODO: Fix this case, though it should never happen,
                    // coming soon movies inherently have a release date
                    return Calendar.current.dateComponents([.year, .month], from: Date())
                }
                return Calendar.current.dateComponents([.year, .month], from: releaseDate)
            })

            let months = movieDict.keys.sorted { (a, b) -> Bool in
                return a.year! > b.year! ? false : a.month! < b.month!
            }
            
            for key in months {
                movieDict[key]?.sort {
                    guard let releaseA = $0.releaseDate else { return false }
                    guard let releaseB = $1.releaseDate else { return true }
                    return releaseA.compare(releaseB) == .orderedAscending
                }
            }
            
            DispatchQueue.main.async {
                self.movies = movieDict
                self.sections = months
                self.tableView.reloadData()
            }
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sections.count <= 1 { return nil }
        
        let components = sections[section]
        guard let date = Calendar.current.date(from: components) else {
            return nil
        }

        let height: CGFloat = sections.count > 1 ? 45.0 : 0.01
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: height)
        let headerView = UIView(frame: frame)
        headerView.backgroundColor = UIColor.clear
        
        let blurView = UIVisualEffectView(frame: frame)
        blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        headerView.addSubview(blurView)
        
        let border = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.5))
        border.backgroundColor = UIColor.separator
//        headerView.addSubview(border)
        
        let title = UILabel(frame: frame.insetBy(dx: 16, dy: 10))
        title.text = DateFormatter.sectionHeader.string(from: date)
        title.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        title.textColor = UIColor.accent
        headerView.addSubview(title)
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
        guard let movie = movies[sections[indexPath.section]]?[indexPath.item] else {
            return cell
        }
        
        cell.tag = movie.id
        cell.set(movie: movie)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    // MARK: - Table Cell Actions
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let addAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "Add") { (action, indexPath) in
            print("TEMP: \(self.movies[self.sections[indexPath.section]]?[indexPath.item].description ?? "Unknown movie")")
        }
        
        addAction.backgroundColor = UIColor.accent

        actions.append(addAction)
        
        return actions
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovie" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            guard let movieDetailsVC = segue.destination as? MovieDetailViewController else { return }
            
            movieDetailsVC.movie = movies[self.sections[indexPath.section]]?[indexPath.item]
        }
    }    
}
