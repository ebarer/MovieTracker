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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MovieTableViewCell
        guard let movie = movies[sections[indexPath.section]]?[indexPath.item] else {
            return cell
        }
        
        cell.backgroundColor = UIColor.bg
        cell.separatorInset = UIEdgeInsets(top: 0, left: 80.0, bottom: 0, right: 0)
        cell.selectionColor = UIColor.selection
        
        cell.movieTitle.text = movie.title

        let dateString = DateFormatter.detailPresentation.string(from: movie.releaseDate)
        cell.movieReleaseDate.text = dateString
        
        cell.moviePoster.image = nil
        
        cell.moviePoster.image = nil
        cell.moviePoster.alpha = 0
        cell.moviePoster.layer.masksToBounds = true
        cell.moviePoster.layer.cornerRadius = 5
        cell.moviePoster.layer.borderWidth = 0.5
        cell.moviePoster.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor

        movie.getPoster { (poster, error, id) in
            guard let fetchID = id,
                  movie.id == fetchID
            else { return }
            
            if error != nil && poster == nil {
                print("Error: couldn't load poster for \(movie.title) - \(error!)")
                cell.moviePoster.image = UIImage(color: UIColor.inactive)
            } else {
                cell.moviePoster.image = poster
            }
            
            UIView.animate(withDuration: 0.5) {
                cell.moviePoster.alpha = 1.0
            }
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
        
        addAction.backgroundColor = UIColor.accent

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
