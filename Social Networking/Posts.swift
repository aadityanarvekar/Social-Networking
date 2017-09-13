//
//  Posts.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/21/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import Foundation

class Post {
    private var _postId: String!
    var postId: String {
        get {
            return _postId
        }
        
        set {
            if newValue.characters.count > 0 {
                _postId = newValue
            }
        }
    }
    
    private var _caption: String!
    var caption: String {
        get {
            return _caption
        }
        
        set {
            if newValue.characters.count > 0 {
                _caption = newValue
            }
        }
    }
    
    private var _imageUrl: String!
    var imageUrl: String {
        get {
            return _imageUrl
        }
        
        set {
            if newValue.characters.count > 0 {
                _imageUrl = newValue
            } else {
                _imageUrl = DEFAULT_POST_IMAGE
            }
        }
    }
    
    private var _likes: Int!
    var likes: Int {
        get {
            return _likes
        }
        
        set {
            if newValue > 0 {
                _likes = likes
            }
        }
    }
    
    private var _postUserId: String!
    var postUserId: String {
        get {
            return _postUserId
        }
    }
    
    private var _postingUser: AppUser!
    var postingUser: AppUser {
        get {
            return _postingUser
        }
        
        set {
            _postingUser = newValue
        }
    }    
    
    init(id: String, caption: String, imageUrl: String, likes: Int, postingUserId: String) {
        _postId = id
        _caption = caption
        self.imageUrl = imageUrl
        _likes = likes
        _postUserId = postingUserId
    }
    
    
    func incrementnumberOfLikes(for post: Post) {
        post.likes += 1
    }
    
}
