//
//  ViewController.swift
//  SuperCoolFlicks
//
//  Created by Eden on 9/12/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import AFNetworking
import KRProgressHUD

class NowPlayingTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var movieList: [[String: Any]] = [[String: Any]]()
    var filteredMovieList: [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self

        segmentedControl.removeBorders()
        collectionView.isHidden = true
        networkErrorLabel.isHidden = true
        
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(font: .systemFont(ofSize: 15))
        KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: .yellow, tail: .red))
        KRProgressHUD.show(withMessage: "Loading movies...")
        
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
    

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
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovieList = searchText.isEmpty ? movieList : movieList.filter { (item: [String: Any]) -> Bool in
            return (item["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }        
        tableView.reloadData()
        collectionView.reloadData()
    }

}


extension NowPlayingTableVC: UICollectionViewDataSource {

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

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y:  0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
//extension UISearchBar {
//    
//    private func getViewElement<T>(type: T.Type) -> T? {
//        
//        let svs = subviews.flatMap { $0.subviews }
//        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
//        return element
//    }
//    
//    func setTextFieldColor(color: UIColor) {
//        
//        if let textField = getViewElement(type: UITextField.self) {
//            switch searchBarStyle {
//            case .minimal:
//                textField.layer.backgroundColor = color.cgColor
//                textField.layer.cornerRadius = 6
//                
//            case .prominent, .default:
//                textField.backgroundColor = color
//            }
//        }
//    }
//}

//        searchBar.setTextFieldColor(color: UIColor.lightGray)
