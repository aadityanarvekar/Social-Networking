//
//  User.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/28/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import Foundation

class AppUser {
    
    private var _postLikes: [String]! = []
    var postLikes: [String] {
        get {
            return _postLikes
        }
        
        set {
            _postLikes = newValue
        }
    }
    
    private var _userPosts: [String]! = []
    var userPosts: [String] {
        get {
            return _userPosts
        }
        
        set {
            _userPosts = newValue
        }
    }
    
    private var _userName: String?
    var userName: String {
        get {
            if let name = _userName {
                return name
            } else {
                return "John Doe"
            }
        }
        set {
            _userName = newValue
        }
    }
    
    private var _provider: String!
    var provider: String {
        get {
            return _provider
        }
    }
    
    private var _photoUrl: URL?
    var photoUrl: URL {
        get {
            if let url = _photoUrl {
                return url
            }
            return DEFAULT_PROFILE_IMAGE
        }
        
        set {
            _photoUrl = newValue
        }
    }
    
    private var _userId: String!
    var userId: String {
        return _userId
    }
    
    
    convenience init(userId: String, userName: String?, provider: String) {
        self.init(userId: userId, userName: userName, provider: provider, photoUrl: DEFAULT_PROFILE_IMAGE)
    }
    
    init(userId: String, userName: String?, provider: String, photoUrl: URL?) {
        _userId = userId
        _userName = userName
        _provider = provider
        _photoUrl = photoUrl        
    }
    
    func toggleLikeStatus(for post: Post) {
        var liked = false
        if doesUserLikePost(post: post) {
            if let index = postLikes.index(of: post.postId) {
                postLikes.remove(at: index)
            }
        } else {
            postLikes.append(post.postId)
            liked = true
        }
        
        DataService.shared.toggleLikeStatus(for: post, liked: liked)
    }
    
    func doesUserLikePost(post: Post) -> Bool {
        return postLikes.contains(post.postId)
    }
    
}
