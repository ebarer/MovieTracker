//
//  UIImageView+Gradient.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/8/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

extension UIView {
    func addGradient(colors: [UIColor], locations: [NSNumber] = [0.0, 1.0]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addGradientView(colors: [UIColor], locations: [NSNumber] = [0.0, 1.0],
                         view: UIView? = nil, frame: CGRect? = nil)
    {
        let gradientView = PassThroughView()
        
        if let subview = view, let frame = frame {
            gradientView.frame = frame
            gradientView.addGradient(colors: colors, locations: locations)
            self.insertSubview(gradientView, aboveSubview: subview)
        } else {
            gradientView.frame = self.frame
            gradientView.addGradient(colors: colors, locations: locations)
            self.insertSubview(gradientView, at: 0)
        }
    }
}

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
