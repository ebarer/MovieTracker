//
//  Person.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/12/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class Person: NSObject {
    var id: Int
    var name: String
    var popularity: Float = 0.0
    var type: PersonType?
    var role: String?
    var profilePicture: String?
    var birthday: Date?
    var imdbID: String?
    var bio: String?
    var credits: [Movie]?
    
    enum PersonType {
        case Cast
        case Crew
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(id: Int, name: String, role: String?, pic: String?, type: PersonType) {
        self.id = id
        self.type = type
        self.name = name
        self.role = role
        self.profilePicture = pic
    }
    
    override var description: String {
        return "[\(id)] \(name)"
    }
}

// MARK: - API Methods

extension Person {
    static func get(id: Int, completionHandler: @escaping (Person?, Error?) -> Void) {
        TMDBWrapper.getPerson(id: id, completionHandler: completionHandler)
    }
    
    static func search(query: String, page: Int, completionHandler: @escaping ([Person]?, Error?, (results: Int, pages: Int)?) -> Void) {
        TMDBWrapper.searchForPeople(query: query, page: page, completionHandler: completionHandler)
    }
    
    func getPicture(width: Person.ProfileSize = .w276, completionHandler: @escaping (UIImage?, Error?, Int?) -> Void) {
        TMDBWrapper.fetchImage(url: self.profilePicture, width: width) { (image, error) in
            completionHandler(image, error, self.id)
        }
    }
}

// MARK: - Image Size Enumerations

extension Person {
    enum ProfileSize: String, ImageSize {
        case w276 = "w276_and_h350_face"
    }
}
