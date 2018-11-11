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
    static let separator    = UIColor(red: 36, green: 36, blue: 36)
    static let accent       = UIColor(red: 218, green: 193, blue: 148)
    static let inactive     = UIColor.separator
    static let selection    = UIColor.separator
    
    static func whiteFaded(a: CGFloat = 0.75) -> UIColor {
        let c = (a < 0 || a > 1) ? 0.75 : a
        return UIColor(red: c, green: c, blue: c, alpha: 1)
    }
}
