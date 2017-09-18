//
//  TopRatedTableVC.swift
//  SuperCoolFlicks
//
//  Created by Eden on 9/14/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import KRProgressHUD
import AFNetworking

class TopRatedTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var loadingMoreView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var isMoreDataLoading = false
    var movieList: [[String: Any]] = [[String: Any]]()
    var filteredMovieList: [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        collectionView.isHidden = true
        networkErrorLabel.isHidden = true
        
        segmentedControl.removeBorders()
        
        flowLayout.minimumLineSpacing = 6
        flowLayout.minimumInteritemSpacing = 2
        
        // Heads Up Display
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(font: .systemFont(ofSize: 15))
        KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: .red, tail: .yellow))
        KRProgressHUD.show(withMessage: "Loading movies...")
        
        // Refresh indicator
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Infinite scrolling indicator
        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        loadingMoreView.center = tableFooterView.center
        tableFooterView.insertSubview(loadingMoreView, at: 0)
        self.tableView.tableFooterView = tableFooterView
        
        // Load data
        fetchMovies(successCallBack: {arrayOfDicts in
            self.movieList = arrayOfDicts
            self.filteredMovieList = arrayOfDicts
            self.tableView.reloadData()
            self.collectionView.reloadData()
            KRProgressHUD.showSuccess(withMessage: "Success!")
        }, errorCallBack: {err in
            print("There was an error: \(err.debugDescription)")
            self.networkErrorLabel.isHidden = false
            KRProgressHUD.set(font: .systemFont(ofSize: 15))
            KRProgressHUD.showError(withMessage: "Unable to load movies.")
        })
        
    }
    
    //    =========================================== TableView Methods ===========================================
    
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
    
    //    =========================================== Other Methods ===========================================
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchMovies(successCallBack: {arrayOfDicts in
            self.movieList = arrayOfDicts
            self.filteredMovieList = arrayOfDicts
            self.tableView.reloadData()
            self.collectionView.reloadData()
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
        let url = URL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=" + Constants.TMDBConstants.apiKey)
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
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            collectionView.isHidden = true
            tableView.isHidden = false
        case 1:
            tableView.isHidden = true
            collectionView.isHidden = false
        default:
            break
        }
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("in prep for segue")
        let movieDetailsVC = segue.destination as! MovieDetailsVC
        print(sender.debugDescription)
        if let cell = sender as? MovieTableViewCell, let indexPath = tableView.indexPath(for: cell) {
            print("inside of if let")
            movieDetailsVC.movie = filteredMovieList[indexPath.row]
        }
        if let cell = sender as? MovieCollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            print("inside of if let")
            movieDetailsVC.movie = filteredMovieList[indexPath.row]
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovieList = searchText.isEmpty ? movieList : movieList.filter { (item: [String: Any]) -> Bool in
            return (item["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                self.loadingMoreView.startAnimating()
                
                fetchMovies(successCallBack: {arrayOfDicts in
                    self.movieList = arrayOfDicts
                    self.filteredMovieList = arrayOfDicts
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    self.isMoreDataLoading = false
                    self.loadingMoreView.stopAnimating()
                }, errorCallBack: {err in
                    print("There was an error: \(err.debugDescription)")
                    self.networkErrorLabel.isHidden = false
                    KRProgressHUD.set(font: .systemFont(ofSize: 15))
                    KRProgressHUD.showError(withMessage: "Unable to load movies.")
                    self.isMoreDataLoading = false
                    self.loadingMoreView.stopAnimating()
                })
            }
        }
    }
    
}


extension TopRatedTableVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath as IndexPath) as! MovieCollectionViewCell
        
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
        
        
        return cell
        
    }
    
}
