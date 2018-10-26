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
    @IBOutlet var overviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setOverview(_ overview: String) {
        overviewLabel.text = overview
        overviewLabel.numberOfLines = 5
    }
}


class ScrollableCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    static let reuseIdentifier = "scrollableCell"
    @IBOutlet var scrollCollectionView: UICollectionView!
    var movie: Movie?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollCollectionView.backgroundColor = UIColor.bg
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCollection(movie: Movie) {
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
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var detailImage: UIImageView!
    var border: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    override func updateConstraints() {
//        super.updateConstraints()
//        let margins = contentView.layoutMarginsGuide
//        border?.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
//        border?.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
//    }
    
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
        
        self.border!.backgroundColor = (index.item == 0) ? UIColor.bg : UIColor.seperator
        self.addSubview(border!)
    }
}
