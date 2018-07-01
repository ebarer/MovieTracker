//
//  TMDBWrapper.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/11/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class TMDBWrapper {
    private static let baseURL = "https://api.themoviedb.org"
    private static let imageBaseURL = "https://image.tmdb.org/t/p"
    private static let apiVersion = "/3"
    private static let apiKey = "da99299f02cd39e2736c97d08b459731"
    
    // Keywords to identify during/after credit extras
    private static let bonusKeywords = ["during" : 179431, "after" : 179430]
}

// MARK: - API Movie Accessors

extension TMDBWrapper {
    static func getMovie(id: Int, completionHandler: @escaping (Movie?, Error?) -> Void) {
        let appendString = "videos,release_dates,credits,keywords"
        var searchURLComponents = URLComponents(string: self.baseURL)!
        searchURLComponents.path = "\(self.apiVersion)/movie/\(id)"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "with_release_type", value: "3|2"),
            URLQueryItem(name: "append_to_response", value: appendString)
        ]

//        TODO: Revert to non-local fetch
//        self.fetchData(url: searchURLComponents) { (data, error) in
        self.fetchLocalData(url: String(id)) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let movieRaw = try decoder.decode(MovieRaw.self, from: data)
                let movie = self.translate(movie: movieRaw)
                completionHandler(movie, nil)
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data: \(error)"))
            }
        }
    }
    
    static func getMoviesNowShowing(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        let dateFormatter = DateFormatter.iso8601DAw
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .month, value: -2, to: today) ?? today
        let endDate = Calendar.current.date(byAdding: .weekday, value: 1, to: today) ?? today
        
        var searchURLComponents = URLComponents(string: self.baseURL)!
        searchURLComponents.path = "\(self.apiVersion)/discover/movie"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "with_release_type", value: "3|2"),
            URLQueryItem(name: "release_date.gte", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "release_date.lte", value: dateFormatter.string(from: endDate)),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "page", value: String(page))
        ]
 
//        TODO: Revert to non-local fetch
//        self.fetchData(url: searchURLComponents) { (data, error) in
        self.fetchLocalData(url: "nowShowing") { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error, nil)
                return
            }
            
            do {
                let root = try decoder.decode(RootRaw.self, from: data)
                let movies = root.movies.map({ self.translate(movie: $0) })
                completionHandler(movies, nil, (root.totalResults, root.totalPages))
            } catch {
                completionHandler(nil, FetchError.decode("Couldn't decode JSON data: \(error)"), nil)
            }
        }
    }
    
    static func getMoviesComingSoon(page: Int, completionHandler: @escaping ([Movie]?, Error?, (results: Int, pages: Int)?) -> Void) {
        let dateFormatter = DateFormatter.iso8601DAw
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .weekday, value: 1, to: today) ?? today
        let endDate = Calendar.current.date(byAdding: Calendar.Component.month, value: 3, to: startDate) ?? startDate
        
        var searchURLComponents = URLComponents(string: self.baseURL)!
        searchURLComponents.path = "\(self.apiVersion)/discover/movie"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "with_release_type", value: "3|2"),
            URLQueryItem(name: "release_date.gte", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "release_date.lte", value: dateFormatter.string(from: endDate)),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        self.fetchData(url: searchURLComponents) { (data, error) in
            guard error == nil, let data = data else {
                completionHandler(nil, error, nil)
                return
            }
            
            do {
                let root = try decoder.decode(RootRaw.self, from: data)
                let movies = root.movies.map({ self.translate(movie: $0) })
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

// MARK: - Local JSON Fetch

extension TMDBWrapper {
    static func fetchLocalData(url: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let path = Bundle.main.path(forResource: url, ofType: "json") else {
            completionHandler(nil, FetchError.noData("Invalid JSON file"))
            return
        }
        
        do {
            let responseData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            completionHandler(responseData, nil)
        } catch {
            completionHandler(nil, FetchError.noData("File didn't contain valid JSON data."))
            return
        }
    }
    
    static func fetchLocalImage(url image: String?, width: ImageSize, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        guard let image = image else {
            completionHandler(nil, FetchError.poster("Invalid image URL supplied"))
            return
        }

        guard let path = Bundle.main.path(forResource: image, ofType: nil) else {
            completionHandler(nil, FetchError.noData("Invalid JSON file"))
            return
        }

        if let imageData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) {
            let poster = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                completionHandler(poster, nil)
            }
        }
    }
}

// MARK: - JSON Decoder and Transformer

extension TMDBWrapper {
    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom({ (decoder) -> Date in
            do {
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
            
                if let date = DateFormatter.iso8601DAw.date(from: dateString) {
                    return date
                }
                
                if let date = DateFormatter.iso8601DTw.date(from: dateString) {
                    return date
                }
                
                print("Unable to create data object for string: \(dateString)")
            } catch {
                print("Error: \(error)")
            }
            
            return Date()
        })
        
        return decoder
    }
    
    private static func translate(movie mv: MovieRaw) -> Movie {
        let movie = Movie(id: mv.id, title: mv.title)
        movie.overview = mv.overview
        movie.poster = mv.poster
        movie.background = mv.background
        movie.runtime = mv.runtime
        movie.rating = mv.rating
        movie.popularity = mv.popularity
        movie.imdbID = mv.imdbID
        
        let releaseInfo = mv.certification()
        movie.releaseDate = releaseInfo.1 ?? mv.releaseDate
        movie.certification = releaseInfo.0

        movie.bonusCredits = Movie.Credits(mv.bonusCredits())
        
        // TODO : Parse genres and trailers
        movie.genres = mv.genres()
        movie.trailers = nil
        
        return movie
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
        var rating: Double?
        var popularity: Double?
        var releaseDates: ReleaseDatesRaw?
        var genresRaw: [GenreRaw]?
        var trailers: Videos?
        var imdbID: String?
        var keywords: Keywords?
        
        func certification() -> (String?, Date?) {
            let regionCode = NSLocale.current.regionCode ?? "US"
            
            guard let regionReleases = self.releaseDates?.releases.filter({
                $0.country == regionCode
            })[0] else {
                return (nil, nil)
            }

            var release = regionReleases.dates.filter({ $0.type == .Theatrical })
            if release.count < 1 {
                release = regionReleases.dates.filter({ $0.type == .TheatricalLimited })
            }
            
            guard release.count > 0 else {
                return (nil, nil)
            }
            
            
            if !release[0].certification.isEmpty {
                return (release[0].certification, release[0].releaseDate)
            } else {
                return ("Unavailable", release[0].releaseDate)
            }
        }
        
        func genres() -> [String]? {
            guard let genres = genresRaw else {
                return nil
            }
            
            if genres.count > 2 {
                return genres[0..<2].map({ $0.name })
            } else{
                return genres.map({ $0.name })
            }
        }
        
        func bonusCredits() -> (during: Bool, after: Bool) {
            var duringCredits = false
            var afterCredits = false
            
            guard keywords != nil, let keywords = keywords?.keywords else {
                return (duringCredits, afterCredits)
            }
            
            for keyword in keywords {
                if keyword.id == TMDBWrapper.bonusKeywords["during"] {
                    duringCredits = true
                }
                
                if keyword.id == TMDBWrapper.bonusKeywords["after"] {
                    afterCredits = true
                }
            }
            
            return (duringCredits, afterCredits)
        }
        
        enum CodingKeys: String, CodingKey {
            case id, title, overview, runtime, popularity, keywords
            case imdbID = "imdb_id"
            case releaseDate = "release_date"
            case poster = "poster_path"
            case background = "backdrop_path"
            case rating = "vote_average"
            case releaseDates = "release_dates"
            case genresRaw = "genres"
            case trailers = "videos"
        }

        struct GenreRaw: Codable {
            var name: String
        }
        
        struct Keywords: Codable {
            var keywords: [KeywordRaw]
        }
        
        struct KeywordRaw: Codable {
            var id: Int
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
                    var type: ReleaseType
                    var releaseDate: Date
                    var certification: String
                    
                    enum CodingKeys : String, CodingKey {
                        case type, certification
                        case releaseDate = "release_date"
                    }
                    
                    enum ReleaseType: Int, Codable {
                        case Premiere = 1
                        case TheatricalLimited = 2
                        case Theatrical = 3
                        case Digital = 4
                        case Physical = 5
                        case TV = 6
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
