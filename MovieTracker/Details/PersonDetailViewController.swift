//
//  PersonDetailViewController.swift
//  MovieTracker
//
//  Created by Elliot Barer on 11/2/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

class PersonDetailViewController: UIViewController {
    // Constants
    let NUM_SECTIONS = 2
    let SECTION_HEADER = 0
    let SECTION_CREDITS = 1
    let ROWS_HEADER = 1
    
    // Properties
    var person: Person?
    var tintColor: UIColor?
    
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
}

// MARK: - Lifecycle

extension PersonDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let person = person else { return }
        retrieveData(for: person)
        setupView()

        navigationItem.title = person.name
        navigationController?.navigationBar.tintColor = self.tintColor ?? UIColor.accent
    }

    override func viewWillAppear(_ animated: Bool) {
        // Hide navigation stack navigation bar, replace with my own
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : self.tintColor as Any]
        self.navigationController?.navigationBar.tintColor = self.tintColor

        // Remove selection (if selection)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
}

// MARK: - View Methods

extension PersonDetailViewController {
    func setupView() {
        navigationItem.title = ""
        
        if let tintColor = self.tintColor {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : tintColor]
        }
        
        // Setup table
        tableView.backgroundColor = UIColor.bg
        tableView.separatorColor = UIColor.separator
        tableView.showsVerticalScrollIndicator = false

        // Configure nav bar
        let backImage = UIImage(named: "BackButton")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(navigateBack))
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
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UINavigationBar Delegates

extension PersonDetailViewController: UINavigationBarDelegate, UIGestureRecognizerDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Table View Data Source + Delegate

extension PersonDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NUM_SECTIONS
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == SECTION_HEADER) ? 0.01 : 45.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_CREDITS:
            return "Movies"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == SECTION_HEADER) ? ROWS_HEADER : person?.credits?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(indexPath: indexPath)
    }
    
    func heightForRow(indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 0, section: SECTION_HEADER) {
            return UITableView.automaticDimension
        } else if indexPath.section == SECTION_CREDITS {
            return 70.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Biography cell
        if indexPath == IndexPath(item: 0, section: SECTION_HEADER) {
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonBiographyCell.reuseIdentifier, for: indexPath) as! PersonBiographyCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = .none
            cell.tintColor = self.tintColor
            cell.set(person: person)
            return cell
        }
        // TODO: Best Known cell
        // Movie cell
        else if indexPath.section == SECTION_CREDITS {
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
            if let person = person, indexPath.item < person.credits?.count ?? 0 {
                let movie = person.credits![indexPath.item]
                if cell.tag != movie.id {
                    cell.tag = movie.id
                    cell.set(movie: movie)
                }
                cell.tintColor = self.tintColor
                cell.selectionStyle = .default
            }
            
            return cell
        // Detail cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.selectionStyle = .default
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle biography text expansion
        if indexPath == IndexPath(item: 0, section: SECTION_HEADER) {
            if let cell = tableView.cellForRow(at: indexPath) as? PersonBiographyCell {
                cell.setSelected(false, animated: false)
                cell.biographyLabel.numberOfLines =
                    (cell.biographyLabel.numberOfLines == 0) ? 5 : 0
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
}

// MARK: - Navigation

extension PersonDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovie" {
            guard let cell = sender as? MovieTableViewCell,
                  let movie = cell.movie,
                  let movieDetailsVC = segue.destination as? MovieDetailViewController
            else { return }

            movieDetailsVC.movie = movie
        }
    }
    
    @objc func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func navigateToRoot() {
        if let vcStack = self.navigationController?.viewControllers,
               vcStack.count > 1,
               vcStack[1] != self
        {
            print(vcStack[1].navigationItem.title ?? "Unknown")
            self.navigationController?.popToViewController(vcStack[1], animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
