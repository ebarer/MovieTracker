//
//  PersonDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/2/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class PersonDetailViewController: UIViewController {
    // Properties
    var person: Person?
    var populated: Bool = false
    var tintColor: UIColor?
    
    // MARK: - Outlets
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
}

// MARK: - Lifecycle

extension PersonDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let person = person else { return }
        retrieveData(for: person)
        setupView()

        navigationController?.navigationBar.tintColor = self.tintColor ?? UIColor.accent
    }
}

// MARK: - View Methods

extension PersonDetailViewController {
    func setupView() {
        // Setup table
//        backgroundAI.startAnimating()
//        posterAI.startAnimating()
    }
    
    func retrieveData(for person: Person) {
        Person.get(id: person.id) { (person, error) in
            guard error == nil, let person = person else {
                print("Error: \(error!)")
                return
            }

            DispatchQueue.main.async {
                print("Fetched: \(person)")
                self.person = person
                self.populateData()
                self.getImages()
            }
        }
    }
    
    func populateData() {
        guard let person = self.person else { return }
        
        print(person.id)
        print(person.name)
        print(person.profilePicture ?? "No profile picture")
        print(person.popularity)
        print(person.imdbID ?? "No IMDB ID")
        print(person.birthday?.toString() ?? "No birthday")
        print(person.bio ?? "No bio")
        
        nameLabel.text = person.name
        
        if let credits = person.credits {
            for movie in credits {
                print(movie)
            }
        }
        
        if !populated {
            populated = true
        }
    }
    
    func getImages() {
        guard let person = self.person else { return }
        
        person.getPicture(width: .w276) { (image, error, _) in
            if error != nil && image == nil {
                print("Error: couldn't load profile picture - \(error!)")
                self.profilePicture.image = UIImage(color: UIColor.inactive)
            } else {
                self.profilePicture.image = image
            }
            
            self.profilePicture.layer.masksToBounds = true
            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
            self.profilePicture.layer.borderWidth = 0.5
            self.profilePicture.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
//            self.posterAI.stopAnimating()
        }
    }
    
}
