//
//  MovieTrackerTests.swift
//  MovieTrackerTests
//
//  Created by Elliot Barer on 5/31/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import XCTest
@testable import MovieTracker

class TMDBWrapperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetMovie() {
        let movieID = 299536  // Avengers: Infinity War (2018)
        TMDBWrapper.getMovie(id: movieID) { (movie, error) in
            
        }
    }
    
}
