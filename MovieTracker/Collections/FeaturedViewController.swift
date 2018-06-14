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
        // Switching to Now Playing view
        case 0:
            self.containerNowPlaying.isHidden = false
            self.containerNowPlaying.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.containerComingSoon.alpha = 0
                self.containerNowPlaying.alpha = 1
            }) { (_) in
                self.containerComingSoon.isHidden = true
            }
        // Switching to Coming Soon view
        case 1:
            self.containerComingSoon.isHidden = false
            self.containerComingSoon.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.containerNowPlaying.alpha = 0
                self.containerComingSoon.alpha = 1
            }) { (_) in
                self.containerNowPlaying.isHidden = true
            }
        default: break
        }
    }
}
