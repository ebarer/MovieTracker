//
//  UIButton+ImageContentMode.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/10/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

// Inspectable image content mode
extension UIButton {
    /// 0 => .ScaleToFill
    /// 1 => .ScaleAspectFit
    /// 2 => .ScaleAspectFill
    @IBInspectable
    var imageContentMode: Int {
        get {
            return self.imageView?.contentMode.rawValue ?? 0
        }
        set {
            if let mode = UIView.ContentMode(rawValue: newValue),
                self.imageView != nil {
                self.imageView?.contentMode = mode
            }
        }
    }
}
