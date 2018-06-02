//
//  MovieGluAPI.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import Foundation
import CoreLocation

class Movie: NSObject {
    var id: UInt
    var title: String
    var releaseDate: Date
    var poster: String?
    var overview: String?
    var rating: Float?
    var viewed: Bool

    init(json: [String: Any]) throws {
        // Extract id
        guard let id = json["id"] as? UInt else {
            throw SerializationError.missing("id")
        }
        
        // Extract title
        guard let title = json["title"] as? String else {
            throw SerializationError.missing("title")
        }
        
        // Extract and validate release date
        guard let releaseDateString = json["release_date"] as? String else {
            throw SerializationError.missing("release_date")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let releaseDate = dateFormatter.date(from: releaseDateString) else {
            throw SerializationError.invalid("date", releaseDateString)
        }
        
        // Initialize properties
        self.id = id
        self.title = title
        self.releaseDate = releaseDate
        self.viewed = false
        
        // Extract poster
        if let posterString = json["poster_path"] as? String {
            self.poster = "https://image.tmdb.org/t/p/w185/\(posterString)"
        } else {
            self.poster = nil
        }
        
        // Extract overview
        if let overview = json["overview"] as? String {
            self.overview = overview
        }
        
        // Extract rating
        if let rating = json["vote_average"] as? String {
            self.rating = (rating as NSString).floatValue
        }
    }
}

// MARK: - Print all values
extension Movie {
    override var description : String {
        return "\(self.id) | \(self.title) (\(self.rating ?? 0.0)): \(self.releaseDate)"
    }
}

extension Movie {
    static func nowShowing(completion: @escaping ([Movie]) -> Void) {
        self.fetch(path: "movie/now_playing", sort: "release_date.desc", completion: completion);
    }
    
    static func comingSoon(completion: @escaping ([Movie]) -> Void) {
        self.fetch(path: "movie/upcoming", sort: "release_date.desc", completion: completion);
    }
}

extension Movie {
    private static func fetch(path: String, sort: String, completion: @escaping ([Movie]) -> Void) {
        var searchURLComponents = URLComponents(string: "https://api.themoviedb.org/")!
        searchURLComponents.path = "/3/\(path)"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "da99299f02cd39e2736c97d08b459731"),
            URLQueryItem(name: "sort_by", value: sort),
            URLQueryItem(name: "region", value: "US"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "include_adult", value: "false")
        ]
        
        guard let searchURL = searchURLComponents.url else {
            return
        }
        
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            var movies: [Movie] = []
            
            if let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let json = jsonObject
            {
                for case let result in json["results"] as! [[String: Any]] {
                    if let movie = try? Movie(json: result) {
                        movies.append(movie)
                    }
                }
            }

            // Ensure movies are sorted correctly when using dates
            switch sort {
            case "release_date.asc":
                movies.sort { $0.releaseDate.compare($1.releaseDate) == .orderedAscending }
            case "release_date.desc":
                movies.sort { $0.releaseDate.compare($1.releaseDate) == .orderedDescending }
            default: break
            }
            
            completion(movies)
        }.resume()
    }
}

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
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
