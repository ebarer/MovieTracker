//
//  ViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Movie.nowShowing(results: "10") { movies in
            for (index, movie) in movies.enumerated() {
                print("\(index): \(movie.title) - \(movie.poster ?? "No poster")")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

