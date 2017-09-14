//
//  TopRatedTableVC.swift
//  SuperCoolFlicks
//
//  Created by Eden on 9/14/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import KRProgressHUD

class TopRatedTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movieList: [[String: Any]] = [[String: Any]]()
    var filteredMovieList: [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        //        searchBar.barTintColor = UIColor.black
        networkErrorLabel.isHidden = true
        
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(font: .systemFont(ofSize: 15))
        KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: .yellow, tail: .red))
        KRProgressHUD.show(withMessage: "Loading movies...")
        
        fetchMovies(successCallBack: {arrayOfDicts in
            self.movieList = arrayOfDicts
            self.filteredMovieList = arrayOfDicts
            self.tableView.reloadData()
            KRProgressHUD.showSuccess(withMessage: "Success!")
        }, errorCallBack: {err in
            print("There was an error: \(err.debugDescription)")
            self.networkErrorLabel.isHidden = false
            KRProgressHUD.set(font: .systemFont(ofSize: 15))
            KRProgressHUD.showError(withMessage: "Unable to load movies.")
        })
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchMovies(successCallBack: {arrayOfDicts in
            self.movieList = arrayOfDicts
            self.filteredMovieList = arrayOfDicts
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }, errorCallBack: {err in
            print("There was an error: \(err.debugDescription)")
            self.networkErrorLabel.isHidden = false
            KRProgressHUD.set(font: .systemFont(ofSize: 15))
            KRProgressHUD.showError(withMessage: "Unable to load movies.")
            refreshControl.endRefreshing()
        })
        
    }
    
    func fetchMovies(successCallBack: @escaping ([[String: Any]]) -> (), errorCallBack: ((Error?) -> ())?) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
            { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    
                    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    successCallBack(dictionary["results"] as! [[String:Any]])
                    
                } else {
                    if let error = error {
                        errorCallBack?(error)
                    }
                }
        });
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredMovieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell") as! MovieTableViewCell
        
        // set imageView and labels
        let currentMovieDic = filteredMovieList[indexPath.row]
        guard let posterImagePath = currentMovieDic["poster_path"] as? String else {
            print("There was an error getting poster_path")
            return cell
        }
        let url = URL(string: Constants.TMDBConstants.imagePath + posterImagePath)
        cell.movieImageView.setImageWith(url!)
        
        guard let movieTitle = currentMovieDic["title"] as? String else {
            print("There was an error getting title")
            return cell
        }
        cell.movieTitleLabel.text = movieTitle
        
        guard let movieDescription = currentMovieDic["overview"] as? String else {
            print("There was an error getting overview")
            return cell
        }
        cell.movieDescriptionLabel.text = movieDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("in prep for segue")
        let movieDetailsVC = segue.destination as! MovieDetailsVC
        print(sender.debugDescription)
        if let cell = sender as? MovieTableViewCell, let indexPath = tableView.indexPath(for: cell) {
            print("inside of if let")
            movieDetailsVC.movie = filteredMovieList[indexPath.row]
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovieList = searchText.isEmpty ? movieList : movieList.filter { (item: [String: Any]) -> Bool in
            return (item["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
}
