//
//  FeedTableViewCell.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/19/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import UIKit

protocol PostLiked {
    func handleUserLikedPost(post: Post, liked: Bool)
}

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postUserProfileImg: UIImageView!
    @IBOutlet weak var postUserName: UILabel!
    @IBOutlet weak var postLikeImg: UIImageView!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var numberOfLikes: UILabel!
    
    var selectedPost: Post?
    var postLikedDelegate: PostLiked?        
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewCell.toggleLikeStatus))
        postLikeImg.addGestureRecognizer(tapGesture)
    }
    
    func configureFeedCell(post: Post, postImg: UIImage? = nil, postUserImg: UIImage? = nil) {
        selectedPost = post
        postDescription.text = post.caption
        numberOfLikes.text = "\(post.likes)"
        
        if let postImage = postImg {
            self.postImg.image = postImage
            self.postImg.contentMode = .scaleAspectFill
        } else {
            if let imageUrl = URL(string: post.imageUrl) {
                URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, res, err) in
                    if err == nil {
                        if let _ = data {
                            DispatchQueue.main.async {
                                let postImage = UIImage(data: data!)
                                self.postImg.image = postImage
                                self.postImg.contentMode = .scaleAspectFill
                                
                                // TODO: Cache image
                                IMAGE_CACHE.setObject(postImage!, forKey: post.imageUrl as NSString)
                            }
                        }
                    } else {
                        print("Unable to download image from url: \(err.debugDescription)")
                    }
                }).resume()                        
            }

        }
        
        if let usr = DataService.shared.appUser {
            if usr.doesUserLikePost(post: post) {
                postLikeImg.image = UIImage(named: "filled-heart")
            } else {
                postLikeImg.image = UIImage(named: "empty-heart")
            }
        }
        
        DataService.shared.downloadUserDetailsOfUser(for: post) {
            self.postUserName.text = post.postingUser.userName
            if let userImg = postUserImg {
                self.postUserProfileImg.image = userImg
                self.postUserProfileImg.contentMode = .scaleAspectFill
            } else {
                let imgUrl = post.postingUser.photoUrl
                URLSession.shared.dataTask(with: imgUrl, completionHandler: { (data, response, err) in
                    guard err == nil, data != nil else { return }
                    DispatchQueue.main.async {
                        let postUserImage = UIImage(data: data!)
                        self.postUserProfileImg.image = postUserImage
                        self.postUserProfileImg.contentMode = .scaleAspectFill
                        IMAGE_CACHE.setObject(postUserImage!, forKey: imgUrl.absoluteString as NSString)
                    }
                }).resume()
            }
        }
        
    }
    
    func toggleLikeStatus() {
        print("Tap gesture recognized")
        guard let post = selectedPost, let user = DataService.shared.appUser else { return }
        var like = false
        if user.doesUserLikePost(post: post) {
            postLikeImg.image = UIImage(named: "empty-heart")
        } else {
            postLikeImg.image = UIImage(named: "filled-heart")
            like = true
        }
        user.toggleLikeStatus(for: post)
        postLikedDelegate?.handleUserLikedPost(post: post, liked: like)
    }
}
