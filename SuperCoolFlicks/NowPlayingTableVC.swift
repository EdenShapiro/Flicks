//
//  ViewController.swift
//  SuperCoolFlicks
//
//  Created by Eden on 9/12/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import AFNetworking

class NowPlayingTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var movieList: [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchMovies(successCallBack: {dic in
            self.movieList = dic
            print("Movie list:")
            print(self.movieList)
            self.tableView.reloadData()
        }, errorCallBack: {err in
            print("There was an error: \(err.debugDescription)")
            //display error message
            })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//                    print(dictionary)
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
        return self.movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell") as! MovieTableViewCell
        
        // set imageView and labels
        let currentMovieDic = movieList[indexPath.row]
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
        
        let movieDetailsVC = MovieDetailsVC()
        movieDetailsVC.movie = movieList[indexPath.row]
        
//        if let posterPath = movie["poster_path"] as? String {
//            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
//            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
//            cell.posterView.setImageWithURL(posterUrl!)
//        }
//        else {
//            // No poster image. Can either set to nil (no image) or a default movie poster image
//            // that you include as an asset
//            cell.posterView.image = nil
//        }

        
                
        self.navigationController!.pushViewController(movieDetailsVC, animated: true)
        
//            let url = URL(string: "https://image.tmdb.org/t/p/w640/l1yltvzILaZcx2jYvc5sEMkM7Eh.jpg")
//            movieDetailsVC.movieImageView.setImageWith(url!)
//            movieDetailsVC.movieTitleLabel.text = "Jaws"
//            movieDetailsVC.movieDescriptionLabel.text = "An insatiable great white shark terrorizes the townspeople of Amity Island, The police chief, an oceanographer and a grizzled shark hunter seek to destroy the bloodthirsty beast."
        
    }
    
    


}

