//
//  MovieDetailTableViewCells.swift
//  MovieTracker
//
//  Created by Elliot Barer on 10/15/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class OverviewCell: UITableViewCell {
    static let reuseIdentifier = "overviewCell"
    
    // MARK: - Outlets
    
    @IBOutlet var overviewLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(overview: String?) {
        overviewLabel.text = overview
        overviewLabel.numberOfLines = 5
    }
}

class ScrollableCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    static let reuseIdentifier = "scrollableCell"
    var movie: Movie?
    
    // MARK: - Outlets
    @IBOutlet var scrollCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollCollectionView.backgroundColor = UIColor.bg
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCollection(movie: Movie?) {
        self.movie = movie
        self.scrollCollectionView.reloadData()
    }
    
// MARK: - UICollectionView Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        switch indexPath.item {
        case 0:
            width = 105.0
        default:
            width = 100.0
        }
        
        return CGSize(width: width, height: 90.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollableCellMovieDetail.reuseIdentifier, for: indexPath) as! ScrollableCellMovieDetail
        cell.configure(with: self.movie, indexPath: indexPath)
        return cell
    }
}

class ScrollableCellMovieDetail: UICollectionViewCell {
    static let reuseIdentifier = "scrollableCellMovieDetail"
    
    // MARK: - Outlets
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var detailImage: UIImageView!
    var border: UIView?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with movie: Movie?, indexPath: IndexPath) {
        guard let movie = movie else { return }
        
        self.detailImage.isHidden = true
        self.detailLabel.isHidden = false
        
        switch indexPath.item {
        case 0:
            self.headerLabel.text = "GENRE"
            let genresString = movie.genresString
            self.detailLabel.text = genresString
            let size: CGFloat = genresString.contains("&") ? 14.0 : 17.0
            self.detailLabel.font = UIFont.systemFont(ofSize: size)
        case 1:
            self.headerLabel.text = "RATING"
            if let certification = movie.certification,
               let certImage = UIImage(named: "Cert-\(certification)")
            {
                self.detailImage.image = certImage
                self.detailImage.tintColor = UIColor.white
                self.detailImage.isHidden = false
                self.detailLabel.isHidden = true
            } else {
                self.detailLabel.text = "N/A"
                self.detailLabel.font = UIFont.systemFont(ofSize: 17.0)
            }
        case 2:
            self.headerLabel.text = "CREDIT CLIPS"
            
            var fontSize: CGFloat = 17.0
            var bonusCredits: String
            switch movie.bonusCredits.raw {
            case (false, false):
                bonusCredits = "None"
            case (false, true):
                bonusCredits = "After"
            case (true, false):
                bonusCredits = "During"
            case (true, true):
                fontSize = 14.0
                bonusCredits = "During &\n After"
            }
            
            self.detailLabel.text = bonusCredits
            self.detailLabel.font = UIFont.systemFont(ofSize: fontSize)
        case 3:
            self.headerLabel.text = "TMDB.org"
            if let rating = movie.rating, rating > 0 {
                self.detailLabel.text = String(format: "%.1f / 5", rating / 2)
            } else {
                self.detailLabel.text = "N/A"
            }
            self.detailLabel.font = UIFont.systemFont(ofSize: 17.0)
        default: break
        }
        
        addBorder(index: indexPath)
    }
    
    func addBorder(index: IndexPath) {
        let offset: CGFloat = 10
        let height = self.frame.height - (2 * offset)
        self.border = UIView(frame: CGRect(x: 0,
                                           y: offset,
                                           width: 1.0,
                                           height: height))
        
        self.border!.backgroundColor = (index.item == 0) ? UIColor.bg : UIColor.separator
        self.addSubview(border!)
    }
}

class CastCell: UITableViewCell {
    static let reuseIdentifier = "castCell"
    var castMember: Movie.Cast?

    // MARK: - Outlets
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup seperator inset
        let leftInset = separatorInset.left + 45 + 12 // leftInset + picture + margin
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        
        // Set selection color
        self.selectedBackgroundView = UIView(frame: self.frame)
        self.selectedBackgroundView!.backgroundColor = UIColor.selection
    }
    
    func set(castMember: Movie.Cast, for movie: Movie) {
        self.castMember = castMember
        
        nameLabel.text = castMember.name

        if let role = castMember.role {
            if castMember.type == .Actor {
                let roleString = NSMutableAttributedString(string: "as \(role)", attributes: [.foregroundColor : self.tintColor])
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
        profilePicture.layer.cornerRadius = 22.0
        profilePicture.layer.borderWidth = 0.5
        profilePicture.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        let id = NSNumber(integerLiteral: castMember.id)
        let cache = (UIApplication.shared.delegate as! AppDelegate).imageCache
        if let image = cache.object(forKey: id) as? UIImage {
            self.profilePicture.image = image
            
            UIView.animate(withDuration: 0.5) {
                self.profilePicture.alpha = 1.0
            }
        } else if let url = castMember.profilePicture {
            movie.getCastPicture(id: castMember.id, url: url, completionHandler: { (image, error, fetchID) in
                guard let fetchID = fetchID,
                      fetchID == castMember.id
                else { return }
                
                if error != nil && image == nil {
                    print("Error: couldn't load profile picture - \(error!)")
                    self.profilePicture.image = UIImage(color: UIColor.inactive)
                } else {
                    self.profilePicture.image = image
                    cache.setObject(image!, forKey: id)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.profilePicture.alpha = 1.0
                }
            })
        }
    }
}
