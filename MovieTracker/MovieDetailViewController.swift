//
//  MovieDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    
    var movie: Movie?
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet var movieOverview: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieTitle.text = movie?.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        if let date = movie?.releaseDate {
            let dateString = dateFormatter.string(from: date)
            self.movieDescription.text = "\(dateString) — Genres"
        }
        
        self.movieOverview.text = movie?.overview
        
//        movie?.getDetails(completionHandler: { (movie, _) in
//            print(movie)
//        })
        
        movie?.getBackground(completionHandler: { (background, error) in
            self.backgroundImage.image = background
        })
        
        movie?.getPoster(width: .w500, completionHandler: { (poster, _) in
            self.moviePoster.image = poster
            self.moviePoster.layer.masksToBounds = true
            self.moviePoster.layer.cornerRadius = 5
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadBackground() {
        guard let movie = movie else { return }
        
        if let posterURLString = movie.poster,
            let posterURL = URL(string: posterURLString)
        {
            URLSession.shared.dataTask(with: posterURL) { (data, response, error) in
                if let poster = data {
                    DispatchQueue.main.async {
                        self.backgroundImage.image = UIImage(data: poster)
                    }
                }
            }.resume()
        }
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
