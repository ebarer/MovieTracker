//
//  PosterDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/10/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class PosterDetailViewController: UIViewController, UIScrollViewDelegate {
    var movie: Movie?
    var tintColor: UIColor?
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var posterAI: UIActivityIndicatorView!
    @IBOutlet var posterView: UIImageView!
    @IBOutlet var posterHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movie = movie else {
            self.dismissView()
            return
        }

        dismissButton.tintColor = self.tintColor ?? UIColor.accent
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        
        let blurView = UIVisualEffectView(frame: self.view.frame)
        blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        self.view.insertSubview(blurView, belowSubview: posterView)
        
        posterView.backgroundColor = UIColor.clear
        posterView.contentMode = .scaleAspectFit
        
        let id = NSNumber(integerLiteral: movie.id)
        let cache = (UIApplication.shared.delegate as! AppDelegate).imageCache
        if let poster = cache.object(forKey: id) as? UIImage {
            configureView(with: poster)
        } else {
            posterAI.startAnimating()
            movie.getPoster(width: .orig) { (poster, error, _) in
                if error != nil && poster == nil {
                    print("Error: couldn't load poster - \(error!)")
                    self.dismissView()
                } else {
                    cache.setObject(poster!, forKey: id)
                    self.configureView(with: poster!)
                    self.posterAI.stopAnimating()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureView(with poster: UIImage) {
        self.posterView.image = poster
        self.posterView.layer.masksToBounds = true
        self.posterView.layer.cornerRadius = 10
        self.posterView.layer.borderWidth = 0.5
        self.posterView.layer.borderColor = UIColor(white: 1, alpha: 0.20).cgColor
        
        let ratio = poster.size.height / poster.size.width
        let newHeight = self.posterView.frame.width * ratio
        self.posterHeight.constant = newHeight
        self.posterView.layoutIfNeeded()
    }
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.posterView
    }

}
