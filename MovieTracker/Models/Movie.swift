//
//  MovieGluAPI.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

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
    
    override var description: String {
        return "[\(id)] \(title) - \(releaseDate) - \(rating != nil ? String(rating!) : "N/A")"
    }
    
    override init() {
        self.id = 0
        self.title = ""
        self.releaseDate = Date()
        super.init()
    }
}

// MARK: - Static REST API methods

extension Movie {
    static func get(movieID: Int, completionHandler: @escaping (Movie?, Error?) -> Void) {
        var searchURLComponents = URLComponents(string: "https://api.themoviedb.org")!
        searchURLComponents.path = "/3/movie/\(movieID)"
        
        self.fetchData(url: searchURLComponents) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let movie = try decoder.decode(Movie.self, from: data)
                completionHandler(movie, nil)
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data"))
            }
        }
    }
    
    static func nowShowing(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .month, value: -2, to: today) ?? today
        let endDate = Calendar.current.date(byAdding: .weekday, value: 1, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Movie.dateFormat
        
        var searchURLComponents = URLComponents(string: "https://api.themoviedb.org")!
        searchURLComponents.path = "/3/discover/movie"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "with_release_type", value: "3|2"),
            URLQueryItem(name: "release_date.gte", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "release_date.lte", value: dateFormatter.string(from: endDate)),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "vote_count.gte", value: "1"),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        self.fetchData(url: searchURLComponents) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error, nil)
                return
            }
            
            do {
                let root = try decoder.decode(Root.self, from: data)
                completionHandler(root.movies, nil, (root.totalResults, root.totalPages))
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data"), nil)
            }
        }
    }
    
    static func comingSoon(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .weekday, value: 1, to: today) ?? today
        let endDate = Calendar.current.date(byAdding: Calendar.Component.month, value: 3, to: startDate) ?? startDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Movie.dateFormat
        
        var searchURLComponents = URLComponents(string: "https://api.themoviedb.org")!
        searchURLComponents.path = "/3/discover/movie"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "with_release_type", value: "3|2"),
            URLQueryItem(name: "release_date.gte", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "release_date.lte", value: dateFormatter.string(from: endDate)),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "vote_count.gte", value: "1"),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        self.fetchData(url: searchURLComponents) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error, nil)
                return
            }
            
            do {
                let root = try decoder.decode(Root.self, from: data)
                completionHandler(root.movies, nil, (root.totalResults, root.totalPages))
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data"), nil)
            }
        }
    }
}

// MARK: - Instance REST API methods

extension Movie {
    func getDetails(completionHandler: @escaping (Movie?, Error?) -> Void) {
        Movie.get(movieID: self.id, completionHandler: completionHandler)
    }
    
    func getPoster(width: PosterSize = .w185, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        self.fetchImage(width: width, completionHandler: completionHandler)
    }
    
    func getBackground(width: BackgroundSize = .w1280, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        self.fetchImage(width: width, completionHandler: completionHandler)
    }
}

// MARK: - Private REST API helper methods

private extension Movie {
    private static let dateFormat = "yyyy-MM-dd"
    
    private enum CodingKeys : String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case poster = "poster_path"
        case background = "backdrop_path"
        case rating = "vote_average"
    }
    
    private struct Root : Codable {
        var movies: [Movie]
        var totalResults: Int
        var totalPages: Int
        
        private enum CodingKeys : String, CodingKey {
            case movies = "results"
            case totalResults = "total_results"
            case totalPages = "total_pages"
        }
    }

    private static var decoder: JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Movie.dateFormat
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
    
    private static func fetchData(url: URLComponents, completionHandler: @escaping (Data?, Error?) -> Void) {
        let regionCode = NSLocale.current.regionCode ?? "US"
        let languageCode = NSLocale.current.languageCode ?? "en"
        
        let queryItems = [
            URLQueryItem(name: "api_key", value: "da99299f02cd39e2736c97d08b459731"),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "with_original_language", value: languageCode),
            URLQueryItem(name: "language", value: "\(languageCode)-\(regionCode)"),
            URLQueryItem(name: "region", value: regionCode),
            URLQueryItem(name: "certification_country", value: regionCode)
        ]
        
        var searchURLComponents = url
        if searchURLComponents.queryItems == nil {
            searchURLComponents.queryItems = queryItems
        } else {
            searchURLComponents.queryItems?.append(contentsOf: queryItems)
        }
        
        guard let searchURL = searchURLComponents.url else {
            return
        }
        
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET"
        request.cachePolicy = .useProtocolCachePolicy
        
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
    
    private enum FetchError: Error {
        case noData(String)
        case decode(String)
        case poster(String)
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

// MARK: - Sample JSON output for a movie
//
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
