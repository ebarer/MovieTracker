//
//  NowPlayingTableViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class NowPlayingTableViewController: UITableViewController {
    
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Movie.nowShowing(results: 10) { movies in
//            self.movies.append(contentsOf: movies.sorted { $0.releaseDate.compare($1.releaseDate) == .orderedAscending })
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
        
        Movie.comingSoon(results: 10) { movies in
//            self.movies.append(contentsOf: movies.sorted { $0.releaseDate.compare($1.releaseDate) == .orderedAscending })
            self.movies.append(contentsOf: movies)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.item]
        
        cell.movieTitle.text = movie.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.movieReleaseDate.text = dateFormatter.string(from: movie.releaseDate)
        
        cell.moviePoster.image = nil
        if let posterURLString = movie.poster,
           let posterURL = URL(string: posterURLString)
        {
            URLSession.shared.dataTask(with: posterURL) { (data, response, error) in
                if let poster = data {
                    DispatchQueue.main.async {
                        cell.moviePoster.image = UIImage(data: poster)
                    }
                }
            }.resume()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    // TODO: Temproarily disable selection
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
