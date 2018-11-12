//
//  String+Extension.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/12/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

extension String {
    func shorten() -> String {
        switch self {
        case "Science Fiction":
            return "Sci-Fi"
        case "Documentary":
            return "Doc"
        default:
            return self
        }
    }
}
