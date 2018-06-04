//
//  MovieGluAPI.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

struct Root : Codable {
    var movies: [Movie]

    private enum CodingKeys : String, CodingKey {
        case movies = "results"
    }
}

class Movie: NSObject, Codable {
    var id: Int
    var title: String
    var releaseDate: Date
    var poster: String?
    var background: String?
    var overview: String?
    var runtime: Int?
    var rating: Float?
    var certification: String?
    var viewed: Bool?
    
    private enum CodingKeys : String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case poster = "poster_path"
        case background = "backdrop_path"
        case rating = "vote_average"
    }
    
    override init() {
        self.id = 0
        self.title = ""
        self.releaseDate = Date()
        super.init()
    }
    
    override var description: String {
        return "[\(id)] \(title) - \(releaseDate) - \(rating ?? 0.0)"
    }
}

// MARK: - Static REST API Methods

extension Movie {
    static func get(movieID: Int, completionHandler: @escaping (Movie?, Error?) -> Void) {
        self.fetchData(path: "movie/\(movieID)") { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error)
                return
            }
            
            let movie = try? decoder.decode(Movie.self, from: data)
            completionHandler(movie, nil)
        }
    }
    
    static func nowShowing(page: Int, completionHandler: @escaping ([Movie]?, Error?) -> Void) {
        self.fetchData(path: "movie/now_playing", sort: "popularity.desc", page: page) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error)
                return
            }
            
            let movies = try? decoder.decode(Root.self, from: data).movies
            completionHandler(movies, nil)
        }
    }
    
    static func comingSoon(page: Int, completionHandler: @escaping ([Movie]?, Error?) -> Void) {
        self.fetchData(path: "movie/upcoming", sort: "release_date.desc", page: page) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error)
                return
            }
            
            let movies = try? decoder.decode(Root.self, from: data).movies
            completionHandler(movies, nil)
        }
    }
}

// MARK: - Instance REST API Methods

extension Movie {
    func getDetails(completionHandler: @escaping ([Movie]?, Error?) -> Void) {
        completionHandler(nil, nil)
//        Movie.get(movieID: self.id, completionHandler: completionHandler)
    }
    
    func getPoster(width: PosterSize = .w185, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        self.fetchImage(width: width, completionHandler: completionHandler)
    }
    
    func getBackground(width: BackgroundSize = .w1280, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        self.fetchImage(width: width, completionHandler: completionHandler)
    }
}

// MARK: - REST API Helpers

extension Movie {
    private static var decoder: JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
    
    private static func fetchData(path: String, sort: String? = nil, page: Int? = nil, appendTo: String? = nil, completionHandler: @escaping (Data?, Error?) -> Void) {
        var searchURLComponents = URLComponents(string: "https://api.themoviedb.org/")!
        searchURLComponents.path = "/3/\(path)"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "da99299f02cd39e2736c97d08b459731"),
            URLQueryItem(name: "region", value: "US"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "include_adult", value: "false")
        ]
        
        if let sort = sort {
            let query = URLQueryItem(name: "sort_by", value: sort)
            searchURLComponents.queryItems?.append(query)
        }
        
        if let page = page {
            let query = URLQueryItem(name: "page", value: String(page))
            searchURLComponents.queryItems?.append(query)
        }
        
        if let appendTo = appendTo {
            let query = URLQueryItem(name: "append_to_response", value: appendTo)
            searchURLComponents.queryItems?.append(query)
        }
        
        guard let searchURL = searchURLComponents.url else {
            return
        }
        
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard let responseData = data else {
                completionHandler(nil, FetchError.noData("Response didn't contain any data."))
                return
            }
            
            completionHandler(responseData, nil)
        }.resume()
    }
    
//    private static func fetchDetails(path: String, sort: String? = nil, page: String? = nil, completionHandler: @escaping (Movie?, Error?) -> Void) {
//        URLQueryItem(name: "append_to_response", value: "release_dates")
//    }
    
    private func fetchImage(width: ImageSize, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        var posterURL: URL?
        if let width = width as? PosterSize, let poster = self.poster {
            posterURL = URL(string: "https://image.tmdb.org/t/p/\(width.rawValue)/\(poster)")
        } else if let width = width as? BackgroundSize, let background = self.background {
            posterURL = URL(string: "https://image.tmdb.org/t/p/\(width.rawValue)/\(background)")
        }
        
        guard posterURL != nil else {
            completionHandler(nil, FetchError.poster("Couldn't generate movie image URL"))
            return
        }
        
        URLSession.shared.dataTask(with: posterURL!) { (data, response, error) in
            if let imageData = data {
                let poster = UIImage(data: imageData)
                DispatchQueue.main.async {
                    completionHandler(poster, nil)
                }
            }
        }.resume()
    }
}

// MARK: - Helper Enums

protocol ImageSize {}

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

enum FetchError: Error {
    case noData(String)
    case poster(String)
}

// Sample JSON output for a movie
// {
//    "adult" = 0,
//    "backdrop_path" = "/3P52oz9HPQWxcwHOwxtyrVV1LKi.jpg",
//    "genre_ids" = {
//        28,
//        35,
//        878
//    },
//    "id" = 383498,
//    "original_language" = en,
//    "original_title" = "Deadpool 2",
//    "overview" = "Wisecracking mercenary Deadpool battles ...",
//    "popularity" = "321.086589",
//    "poster_path" = "/to0spRl1CMDvyUbOnbb4fTk3VAd.jpg",
//    "release_date" = "2018-05-17",
//    "title" = "Deadpool 2",
//    "video" = 0,
//    "vote_average" = "7.9",
//    "vote_count" = 1579
// }, ...
