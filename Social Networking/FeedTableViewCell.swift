//
//  FeedTableViewCell.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/19/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postUserProfileImg: UIImageView!
    @IBOutlet weak var postUserName: UILabel!
    @IBOutlet weak var postLikeImg: UIImageView!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var numberOfLikes: UILabel!
    
    var selectedPost: Post?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewCell.toggleLikeStatus))
        postLikeImg.addGestureRecognizer(tapGesture)
    }
    
    func configureFeedCell(post: Post) {
        selectedPost = post
        postDescription.text = post.caption
        numberOfLikes.text = "\(post.likes)"
        if let imageUrl = URL(string: post.imageUrl) {
            URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, res, err) in
                if err == nil {
                    if let _ = data {                        
                        DispatchQueue.main.async {
                            self.postImg.image = UIImage(data: data!)
                            self.postImg.contentMode = .scaleAspectFill
                        }
                    }
                } else {
                    print("Unable to download image from url: \(err.debugDescription)")
                }
            }).resume()
        }
        if let usr = DataService.shared.appUser {
            if usr.doesUserLikePost(post: post) {
                postLikeImg.image = UIImage(named: "filled-heart")
            } else {
                postLikeImg.image = UIImage(named: "empty-heart")
            }
        }
    }
    
    func toggleLikeStatus() {
        print("Tap gesture recognized")
        guard let post = selectedPost, let user = DataService.shared.appUser else { return }
        if user.doesUserLikePost(post: post) {
            postLikeImg.image = UIImage(named: "empty-heart")
        } else {
            postLikeImg.image = UIImage(named: "filled-heart")
        }
        user.toggleLikeStatus(for: post)
    }
    
}
