//
//  PersonDetailTableViewCells.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/13/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class PersonBiographyCell: UITableViewCell {
    // Properties
    static let reuseIdentifier = "personBiographyCell"
    var person: Person?
    
    // MARK: - Outlets
    
    @IBOutlet var profilePictureAI: UIActivityIndicatorView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var biographyLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profilePictureAI.startAnimating()
        profilePictureAI.hidesWhenStopped = true

        profilePicture.image = UIImage(color: UIColor.inactive)
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
        profilePicture.layer.borderWidth = 0.5
        profilePicture.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(person p: Person?) {
        guard let person = p else { return }
        
        self.person = person
        
        nameLabel.text = person.name
        
        var birthdayString = "Unknown"
        if let birthday = person.birthday {
            birthdayString = "\(birthday.toString())"
            
            if let age = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year {
                birthdayString += "  •  \(age) years old"
            }
            
            birthdayLabel.text = birthdayString
            birthdayLabel.textColor = self.tintColor
            birthdayLabel.isHidden = false
        } else {
            birthdayLabel.text = nil
            birthdayLabel.isHidden = true
        }
        
        biographyLabel.text = person.bio
        biographyLabel.numberOfLines = 5
        
        person.getPicture(width: .w276) { (image, error, _) in
            if error != nil && image == nil {
                print("Error: couldn't load profile picture - \(error!)")
                self.profilePicture.image = UIImage(color: UIColor.inactive)
            } else {
                self.profilePicture.image = image
            }
            
            self.profilePictureAI.stopAnimating()
        }
    }
}

// TODO: PersonHeaderCell <-- Biography?
