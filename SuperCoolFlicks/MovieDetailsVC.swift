//
//  MovieDetailsVC.swift
//  SuperCoolFlicks
//
//  Created by Eden on 9/12/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import CoreGraphics

class MovieDetailsVC: UIViewController {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    var movie: [String: Any]!
    
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
        
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 3
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
//        let subviewHeight = CGFloat(120)
//        var currentViewOffset = CGFloat(0);
        
//        while currentViewOffset < contentHeight {
//            let frame = CGRect(x: 0, y: currentViewOffset, width: contentWidth, height: subviewHeight)
////            0, currentViewOffset, contentWidth, subviewHeight).rectByInsetting(dx: 5, dy: 5)
//            let hue = currentViewOffset/contentHeight
//            let subview = UIView(frame: frame)
//            subview.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
//            scrollView.addSubview(subview)
//            
//            currentViewOffset += subviewHeight
//        }
        
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = imageView.frame
//        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
//        gradient.locations = [0.0, 0.1]
//        imageView.layer.insertSublayer(gradient, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
