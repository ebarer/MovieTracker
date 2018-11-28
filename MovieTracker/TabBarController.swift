//
//  TabBarController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/27/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.accent
        self.delegate = self
    }

}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(self.presentedViewController is FeaturedViewController)
        
        guard let navVC = self.presentedViewController?.navigationController else {
            print("Error: invalid navVC")
            return
        }

        let vcStack = navVC.viewControllers
        if vcStack.count > 1 {
            navVC.popToViewController(vcStack[1], animated: true)
        } else {
            navVC.popToRootViewController(animated: true)
        }
        
        print(item)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return false
    }
}
