//
//  TabBarController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/27/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.accent
        self.delegate = self
    }

}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        currentIndex = (self.viewControllers as NSArray?)?.index(of: viewController) ?? -1
        print(selectedIndex, currentIndex)
        if tabBarController.selectedViewController == viewController && currentIndex == 0 {
            if let navVC = viewController as? UINavigationController {
                let vcStack = navVC.viewControllers
                // Deep traversal through multiple movies/people controllers
                if vcStack.count > 2 {
                    // Ensure view is scrolled to top
                    (vcStack[1] as? MovieDetailViewController)?.tableView.setContentOffset(.zero, animated: false)
                    navVC.popToViewController(vcStack[1], animated: true)
                }
                // First movie controller
                else if vcStack.count == 2 {
                    navVC.popToRootViewController(animated: true)
                }
                // Feature collection controller
                else {
                    // Scroll collection view to top
                    let offset = CGPoint(x: 0, y: -1 * vcStack[0].view.safeAreaInsets.top)
                    (vcStack[0] as? FeaturedViewController)?.collectionView.setContentOffset(offset, animated: true)
                }
                
                return false
            }
        }
        
        return true
    }
}
