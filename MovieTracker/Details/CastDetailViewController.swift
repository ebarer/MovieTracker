//
//  CastDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/2/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class CastDetailViewController: UIViewController {
    var castMember: Movie.Cast?
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let castMember = castMember {
            nameLabel.text = castMember.name
        }
    }

}
