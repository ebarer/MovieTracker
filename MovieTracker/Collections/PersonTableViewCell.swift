//
//  PersonTableViewCell.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/12/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    static let reuseIdentifier = "personCell"
    var person: Person?
    
    // MARK: - Outlets
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup seperator inset = leftInset + picture + margin
        let leftInset = separatorInset.left + profilePicture.frame.width + 12
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        
        // Set selection color
        self.selectedBackgroundView = UIView(frame: self.frame)
        self.selectedBackgroundView!.backgroundColor = UIColor.selection
    }
    
    func set(person: Person) {
        self.person = person
        
        nameLabel.text = person.name
        
        if let role = person.role {
            if person.type == .Cast {
                let roleString = NSMutableAttributedString(string: "as \(role)", attributes: [.foregroundColor : self.tintColor!])
                roleString.addAttribute(.foregroundColor, value: UIColor.whiteFaded(a: 0.4), range: NSRange(location: 0, length: 2))
                roleLabel.attributedText = roleString
            } else {
                roleLabel.text = role
                roleLabel.textColor = self.tintColor
            }
        }
        
        profilePicture.image = nil
        profilePicture.alpha = 0
        profilePicture.layer.masksToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
        profilePicture.layer.borderWidth = 0.5
        profilePicture.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        let id = NSNumber(integerLiteral: person.id)
        let cache = (UIApplication.shared.delegate as! AppDelegate).imageCache
        if let image = cache.object(forKey: id) as? UIImage {
            self.setImage(image: image)
        } else {
            person.getPicture { (image, error, fetchID) in
                guard self.tag == person.id else {
                    self.setImage(image: UIImage(color: UIColor.inactive))
                    return
                }
                
                if error != nil && image == nil {
                    self.setImage(image: UIImage(color: UIColor.inactive))
                } else {
                    cache.setObject(image!, forKey: id)
                    self.setImage(image: image)
                }
            }
        }
    }
    
    func setImage(image: UIImage?) {
        self.profilePicture.image = image
        UIView.animate(withDuration: 0.5) {
            self.profilePicture.alpha = 1.0
        }
    }
}
