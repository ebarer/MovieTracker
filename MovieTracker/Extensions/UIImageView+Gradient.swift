//
//  UIImageView+Gradient.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/8/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

extension UIImageView {
    func addGradient(colors: [UIColor], locations: [NSNumber] = [0.0, 1.0]){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
