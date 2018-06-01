//
//  MovieGluAPI.swift
//  MovieTracker
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import Foundation
import CoreLocation

class Movie {
    var id: UInt
    var title: String
    var releaseDate: Date
    var poster: String?
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
    }
}

extension Movie {
    static func nowShowing(results: Int, completion: @escaping ([Movie]) -> Void) {
        self.fetch(path: "/filmsNowShowing/", results: String(results), completion: completion);
    }
    
    static func comingSoon(results: Int, completion: @escaping ([Movie]) -> Void) {
        self.fetch(path: "movie/upcoming", results: String(results), completion: completion);
    }
}

extension Movie {
    private static func fetch(path: String, results query: String, completion: @escaping ([Movie]) -> Void) {
        var searchURLComponents = URLComponents(string: "https://api.themoviedb.org/")!
        searchURLComponents.path = "/3/\(path)"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "da99299f02cd39e2736c97d08b459731"),
            URLQueryItem(name: "sort_by", value: "release_date.asc"),
            URLQueryItem(name: "region", value: "US")
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
//    "film_id": 213940,
//    "film_name": "Solo: A Star Wars Story",
//    "release_date": "2018-05-24",
//    "age_rating": "12A ",
//    "age_rating_image": "https://d2z9fe5yu2p0av.cloudfront.net/age_rating_logos/uk/12a.png",
//    "film_trailer": "https://dzm1iom8kpoas.cloudfront.net/213940_high_V3.mp4",
//    "synopsis_long": "Board the Millennium Falcon and ...",
//    "images": {
//        "poster": {
//            "1": {
//                "image_orientation": "portrait",
//                "region": "US",
//                "medium": {
//                    "film_image": "https://d3ltpb4h29tx4j.cloudfront.net/213940/213940h1.jpg",
//                    "width": 200,
//                    "height": 300
//                }
//            }
//        },
//        "still": {
//            "2": {
//                "image_orientation": "landscape",
//                "medium": {
//                    "film_image": "https://d3ltpb4h29tx4j.cloudfront.net/213940/213940h2.jpg",
//                    "width": 300,
//                    "height": 200
//                }
//            }
//        }
//    }
// }, ...
