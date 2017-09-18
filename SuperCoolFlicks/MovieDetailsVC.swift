//
//  MovieDetailsVC.swift
//  SuperCoolFlicks
//
//  Created by Eden on 9/12/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import CoreGraphics
import KRProgressHUD

class MovieDetailsVC: UIViewController {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var runTime: UILabel!
    
    var movie: [String: Any]!
    var movieDetails = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let posterImagePath = movie["poster_path"] as? String {
            let imageURL = URL(string: Constants.TMDBConstants.imagePath + posterImagePath)
            self.movieImageView.setImageWith(imageURL!)
        } else {
            self.movieImageView.image = nil
        }
        
        if let movieTitle = movie["title"] as? String {
            self.movieTitleLabel.text = movieTitle
        } else {
            self.movieTitleLabel.text = ""
        }
        
        if let movieDescription = movie["overview"] as? String {
            self.movieDescriptionLabel.text = movieDescription
        } else {
            self.movieDescriptionLabel.text = ""
        }
        
        if let avgRating = movie["vote_average"] as? Double {
            let percentage = Int(avgRating * 10)
            self.rating.text = String(percentage) + "%"
        } else {
            self.rating.text = ""
        }
    
        if let releaseD = movie["release_date"] as? String {
            let index = releaseD.index(releaseD.startIndex, offsetBy: 4)
            let year = releaseD.substring(to: index)
            self.releaseDate.text = year
        } else {
            self.releaseDate.text = ""
        }
        
        // Heads Up Display
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(font: .systemFont(ofSize: 15))
        KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: .red, tail: .yellow))
        KRProgressHUD.show(withMessage: "Loading details...")
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 3
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        self.navigationController?.navigationBar.tintColor = UIColor.red
        
        self.runTime.text = ""
        
        if let movieID = movie["id"] as? Int {
            
            fetchMovieDetails(movieID: movieID, successCallBack: {dic in
                self.movieDetails = dic
                if let runtime = dic["runtime"] as? Int {
                    self.runTime.text = self.timeHelper(minutes: runtime)
                }
                
                KRProgressHUD.showSuccess(withMessage: "Success!")
            }, errorCallBack: {err in
                print("There was an error: \(err.debugDescription)")
                KRProgressHUD.set(font: .systemFont(ofSize: 15))
                KRProgressHUD.showError(withMessage: "Unable to load movies.")
                self.runTime.text = ""
            })
        } else {
            self.runTime.text = ""
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = movieImageView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.5, 1]
        movieImageView.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func fetchMovieDetails(movieID: Int, successCallBack: @escaping ([String: Any]) -> (), errorCallBack: ((Error?) -> ())?) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/" + String(movieID) + "?api_key=" + Constants.TMDBConstants.apiKey)
        
//        https://api.themoviedb.org/3/movie/{movie_id}?api_key=<<api_key>>&language=en-US
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
                    successCallBack(dictionary)
                    
                } else {
                    if let error = error {
                        errorCallBack?(error)
                    }
                }
        });
        task.resume()
    }
    func timeHelper(minutes: Int) -> String {
        let hours = minutes / 60
        let minutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
        
    }
    

}
