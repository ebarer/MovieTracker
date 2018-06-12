//
//  TMDBWrapper.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/11/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class TMDBWrapper {
    static let dateFormat = "yyyy-MM-dd"
    static let baseURL = "https://api.themoviedb.org"
    static let imageBaseURL = "https://image.tmdb.org/t/p"
    static let apiVersion = "/3"
    static let apiKey = "da99299f02cd39e2736c97d08b459731"
}

// MARK: - API Movie Accessors

extension TMDBWrapper {
    static func getMovie(id: Int, completionHandler: @escaping (Movie?, Error?) -> Void) {
        var searchURLComponents = URLComponents(string: self.baseURL)!
        searchURLComponents.path = "\(self.apiVersion)/movie/\(id)"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "append_to_response", value: "videos,release_dates,credits")
        ]
        
        self.fetchData(url: searchURLComponents) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let movieRaw = try decoder.decode(MovieRaw.self, from: data)
                let movie = self.transformMovies(from: movieRaw)
                completionHandler(movie, nil)
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data: \(error)"))
            }
        }
    }
    
    static func getMoviesNowShowing(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .month, value: -2, to: today) ?? today
        let endDate = Calendar.current.date(byAdding: .weekday, value: 1, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat
        
        var searchURLComponents = URLComponents(string: self.baseURL)!
        searchURLComponents.path = "\(self.apiVersion)/discover/movie"
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
                let root = try decoder.decode(RootRaw.self, from: data)
                let movies = self.transformMovies(from: root)
                completionHandler(movies, nil, (root.totalResults, root.totalPages))
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data: \(error)"), nil)
            }
        }
    }
    
    static func getMoviesComingSoon(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .weekday, value: 1, to: today) ?? today
        let endDate = Calendar.current.date(byAdding: Calendar.Component.month, value: 3, to: startDate) ?? startDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat
        
        var searchURLComponents = URLComponents(string: self.baseURL)!
        searchURLComponents.path = "\(self.apiVersion)/discover/movie"
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
                let root = try decoder.decode(RootRaw.self, from: data)
                let movies = self.transformMovies(from: root)
                completionHandler(movies, nil, (root.totalResults, root.totalPages))
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data: \(error)"), nil)
            }
        }
    }
}

// MARK: - API Fetchers

extension TMDBWrapper {
    static func fetchData(url: URLComponents, completionHandler: @escaping (Data?, Error?) -> Void) {
        let regionCode = NSLocale.current.regionCode ?? "US"
        let languageCode = NSLocale.current.languageCode ?? "en"
        
        let queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
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
    
    static func fetchImage(url image: String?, width: ImageSize, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        guard let image = image else {
            completionHandler(nil, FetchError.poster("Invalid image URL supplied"))
            return
        }
        
        var imageURL: URL?
        
        if let width = (width as? Movie.PosterSize)?.rawValue {
            imageURL = URL(string: "\(self.imageBaseURL)/\(width)/\(image)")
        } else if let width = (width as? Movie.BackgroundSize)?.rawValue {
            imageURL = URL(string: "\(self.imageBaseURL)/\(width)/\(image)")
        }
        
        guard imageURL != nil else {
            completionHandler(nil, FetchError.poster("Couldn't generate movie image URL"))
            return
        }
        
        URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if let imageData = data {
                let poster = UIImage(data: imageData)
                DispatchQueue.main.async {
                    completionHandler(poster, nil)
                }
            }
        }.resume()
    }
}

// MARK: - JSON Decoder and Transformer

extension TMDBWrapper {
    private static var decoder: JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = TMDBWrapper.dateFormat
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
    
    private static func transformMovies(from root: RootRaw) -> [Movie] {
        var movies = [Movie]()
        
        return movies
    }
    
    private static func transformMovies(from movieRaw: MovieRaw) -> Movie? {
        
        return nil
    }
}

// MARK: - JSON Structures

extension TMDBWrapper {
    private struct RootRaw: Codable {
        var movies: [MovieRaw]
        var totalResults: Int
        var totalPages: Int
        
        private enum CodingKeys : String, CodingKey {
            case movies = "results"
            case totalResults = "total_results"
            case totalPages = "total_pages"
        }
    }
    
    struct MovieRaw: Codable {
        var id: Int
        var title: String
        var releaseDate: Date
        var overview: String?
        var poster: String?
        var background: String?
        var runtime: Int?
        var rating: Float?
        var certification: [ReleaseDatesRaw]?
        var genres: [GenreRaw]?
        var trailers: Videos?
        var imdbID: String?
        
        enum CodingKeys: String, CodingKey {
            case id, title, overview, runtime, genres
            case imdbID = "imdb_id"
            case releaseDate = "release_date"
            case poster = "poster_path"
            case background = "backdrop_path"
            case rating = "vote_average"
            case certification = "release_dates"
            case trailers = "videos"
        }

        struct GenreRaw: Codable {
            var name: String
        }

        struct ReleaseDatesRaw: Codable {
            var releases: [ReleaseDateWrapperRaw]
            private enum CodingKeys : String, CodingKey {
                case releases = "results"
            }
        
            struct ReleaseDateWrapperRaw: Codable {
                var country: String
                var dates: [ReleaseDateRaw]
                
                enum CodingKeys : String, CodingKey {
                    case country = "iso_3166_1"
                    case dates = "release_dates"
                }
                
                struct ReleaseDateRaw: Codable {
                    var type: Int
                    var releaseDate: Date
                    var certification: String
                    
                    private enum CodingKeys : String, CodingKey {
                        case type, certification
                        case releaseDate = "release_date"
                    }
                }
            }
        }

        struct Videos: Codable {
            var videos: [Video]
            
            enum CodingKeys : String, CodingKey {
                case videos = "results"
            }
        
            struct Video: Codable {
                var id: String
                var name: String
                var key: String
                var type: TrailerType
                
                enum TrailerType: String, Codable {
                    case Teaser = "Teaser"
                    case Trailer = "Trailer"
                    case Clip = "Clip"
                    case Featurette = "Featurette"
                }
            }
        }
    }
}

enum FetchError: Error {
    case noData(String)
    case decode(String)
    case poster(String)
}
