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
    var populated: Bool = false
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

        navigationController?.navigationBar.tintColor = self.tintColor ?? UIColor.accent
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
        
        if let credits = person.credits {
            for movie in credits {
                print(movie)
            }
        }
        
        self.tableView.reloadData()
        
        if !populated {
            populated = true
        }
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
            cell.set(person: person)
            return cell
        }
        // Detail cell
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
}
