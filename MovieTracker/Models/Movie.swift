//
//  MovieGluAPI.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class Movie: NSObject {
    var id: Int
    var title: String
    var releaseDate: Date
    var overview: String?
    var poster: String?
    var background: String?
    var runtime: Int?
    var rating: Float?
    var certification: String?
    var genres: [String]?
    var trailers: [String]?
    var imdbID: String?
    var tracked: Bool = false
    var watched: Bool = false
    
    var duration: String? {
        guard runtime != nil else { return nil }
        return "\(self.runtime! / 60) hr \(self.runtime! % 60) min"
    }
    
    override var description: String {
        return "[\(id)] \(title) - \(releaseDate) - \(rating != nil ? String(rating!) : "N/A")"
    }
    
    override init() {
        self.id = 0
        self.title = ""
        self.releaseDate = Date()
        super.init()
    }
    
    convenience init(id: Int, title: String, releaseDate: Date, poster: String) {
        self.init()
        self.id = id
        self.title = title
        self.poster = poster
        self.releaseDate = releaseDate
    }
}

// MARK: - API Methods
extension Movie {
    static func get(id: Int, completionHandler: @escaping (Movie?, Error?) -> Void) {
        TMDBWrapper.getMovie(id: id, completionHandler: completionHandler)
    }
    
    static func nowShowing(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        TMDBWrapper.getMoviesNowShowing(page: page, completionHandler: completionHandler)
    }
    
    static func comingSoon(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        TMDBWrapper.getMoviesComingSoon(page: page, completionHandler: completionHandler)
    }
    
    func getPoster(width: Movie.PosterSize = .w185, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        TMDBWrapper.fetchImage(url: self.poster, width: width, completionHandler: completionHandler)
    }
    
    func getBackground(width: Movie.BackgroundSize = .w1280, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        TMDBWrapper.fetchImage(url: self.background, width: width, completionHandler: completionHandler)
    }
}

// MARK: - Image Size Enumerations, Trailer Structure

protocol ImageSize {}
extension Movie {
    enum PosterSize: String, ImageSize {
        case w92  = "w92"
        case w154 = "w154"
        case w185 = "w185"
        case w342 = "w342"
        case w500 = "w500"
        case w780 = "w780"
        case orig = "original"
    }

    enum BackgroundSize: String, ImageSize {
        case w300  = "w300"
        case w780  = "w780"
        case w1280 = "w1280"
        case orig  = "original"
    }
    
    
}
