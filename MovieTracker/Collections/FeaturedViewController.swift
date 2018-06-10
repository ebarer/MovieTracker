//
//  FeaturedViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/9/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet var containerNowPlaying: UIView!
    @IBOutlet var containerComingSoon: UIView!
}

// MARK: - Lifecycle
    
extension FeaturedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        containerNowPlaying.isHidden = false
        containerComingSoon.isHidden = true
    }
}

// MARK: - Segment Event

extension FeaturedViewController {
    @IBAction func featureChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            containerNowPlaying.isHidden = false
            containerComingSoon.isHidden = true
        case 1:
            containerNowPlaying.isHidden = true
            containerComingSoon.isHidden = false
        default: break
        }
    }
}
