//
//  PersonDetailTableViewCells.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/13/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

// TODO: PersonHeaderCell <-- Biography?

class PersonBiographyCell: UITableViewCell {
    static let reuseIdentifier = "personBiographyCell"
    var person: Person?
    
    // MARK: - Outlets
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var biographyLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(person p: Person?) {
        guard let person = p else { return }
        
        self.person = person
        
        nameLabel.text = person.name
        biographyLabel.text = person.bio
        biographyLabel.numberOfLines = 5
        
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
