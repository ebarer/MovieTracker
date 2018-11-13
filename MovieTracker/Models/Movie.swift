//
//  Movie.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class Movie: NSObject {
    var id: Int
    var title: String
    var releaseDate: Date?
    var overview: String?
    var poster: String?
    var background: String?
    var runtime: Int?
    var rating: Double?
    var popularity: Double?
    var certification: String?
    var imdbID: String?
    var genres: [String]?
    var trailers: [String]?
    var bonusCredits: Credits = Credits(during: false, after: false)
    var team: [Person]
    var tracked: Bool = false
    var watched: Bool = false
    
    override init() {
        self.id = 0
        self.title = ""
        self.team = [Person]()
        super.init()
    }
    
    convenience init(id: Int, title: String) {
        self.init()
        self.id = id
        self.title = title
    }
    
    override var description: String {
        return "[\(id)] \(title) - \(releaseDate?.toString() ?? "Unknown") - \(rating != nil ? String(rating!) : "N/A") - \(popularity != nil ? String(popularity!) : "N/A")"
    }

    var duration: String? {
        guard runtime != nil else { return nil }
        return "\(self.runtime! / 60) hr \(self.runtime! % 60) min"
    }
    
    var genresString: String {
        switch self.genres?.count {
        case 1:
            return "\(self.genres![0].shorten())"
        case 2:
            return "\(self.genres![0].shorten()) &\n\(self.genres![1].shorten())"
        default:
            return "N/A"
        }
    }
    
    var bonusString: String {
        switch self.bonusCredits.raw {
        case (false, false):
            return "None"
        case (false, true):
            return "After"
        case (true, false):
            return "During"
        case (true, true):
            return "During + After"
        }
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
    
    static func search(query: String, page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        TMDBWrapper.searchForMovies(query: query, page: page, completionHandler: completionHandler)
    }
    
    func getPoster(width: Movie.PosterSize = .w185, completionHandler: @escaping (UIImage?, Error?, Int?) -> Void) {
        TMDBWrapper.fetchImage(url: self.poster, width: width) { (image, error) in
            completionHandler(image, error, self.id)
        }
    }
    
    func getBackground(width: Movie.BackgroundSize = .w1280, completionHandler: @escaping (UIImage?, Error?, Int?) -> Void) {
        TMDBWrapper.fetchImage(url: self.background, width: width) { (image, error) in
            completionHandler(image, error, self.id)
        }
    }
}

// MARK - Equatable + Hashable

extension Movie {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    override var hash: Int {
        return self.id
    }
}

// MARK: - Subclasses

extension Movie {
    struct Credits {
        var during: Bool
        var after: Bool
        
        init(during: Bool, after: Bool) {
            self.during = during
            self.after = after
        }
        
        init(_ val: (Bool, Bool)) {
            self.during = val.0
            self.after = val.1
        }
        
        var raw: (Bool, Bool) {
            return (self.during, self.after)
        }
    }
}

// MARK: - Image Size Enumerations

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
