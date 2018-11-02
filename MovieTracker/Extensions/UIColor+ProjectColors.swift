//
//  UIColor+ProjectColors.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/1/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    static let bg           = UIColor(red: 12, green: 12, blue: 12)
    static let inactive     = UIColor(red: 37, green: 37, blue: 37)
    static let noImage      = UIColor(red: 37, green: 37, blue: 37)
    static let separator    = UIColor(red: 37, green: 37, blue: 37)
    static let selection    = UIColor(red: 37, green: 37, blue: 37)
    static let gold         = UIColor(red: 218, green: 193, blue: 148)
    
    static func whiteFaded(a: CGFloat = 0.75) -> UIColor {
        return UIColor(red: a, green: a, blue: a, alpha: 1)
    }
}
