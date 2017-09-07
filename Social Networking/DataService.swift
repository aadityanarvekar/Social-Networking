//
//  DataService.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/20/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import Foundation
import Firebase

protocol PostsDownloadComplete {
    func handlePostsUpdated(posts: [Post])
}

protocol UserDetailsDownloadComplete {
    func handleUserDetailsDownloadComplete(user: AppUser)
}

protocol PostingUserDetailsDownloadComplete {
    func updatePostingUserDetails()
}

class DataService {
    var downloadCompleteDelegate: PostsDownloadComplete?
    var userDetailsDownloadCompleteDelegate: UserDetailsDownloadComplete?
    var postingUserDetailsDelgate: PostingUserDetailsDownloadComplete?
    static let shared = DataService()
    var appUser: AppUser?
    var isPostsDownloadComplete = false
    
    func createFirebaseDBUser(with uid: String, userData: Dictionary<String, String>) {
        USERS_REF.child(uid).updateChildValues(userData)
    }
    
    func getUserInformation(uID: String) {
        if let user = appUser {
            userDetailsDownloadCompleteDelegate?.handleUserDetailsDownloadComplete(user: user)
        } else {
            USERS_REF.child(uID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let userInfo = snapshot.value as? Dictionary<String, Any> {
                    guard let name = userInfo["name"] as? String, let photoUrl = userInfo["photoUrl"] as? String, let provider = userInfo["provider"] as? String else {
                        return
                    }
                    let usr = AppUser(userId: uID, userName: name, provider: provider, photoUrl: URL(string: photoUrl))
                    if let likes = userInfo["likes"] as? Dictionary<String, Any> {
                        for key in likes.keys {
                            usr.postLikes.append(key)
                        }
                    }
                    self.appUser = usr
                    self.userDetailsDownloadCompleteDelegate?.handleUserDetailsDownloadComplete(user: usr)
                }
            })
        }
    }
    
    func toggleLikeStatus(for post: Post, liked: Bool) {
        // Add post ID to user
        guard let user = appUser else { return }
        if liked {
            USERS_REF.child("\(user.userId)/likes").updateChildValues([post.postId: "true"])
        } else {
            USERS_REF.child("\(user.userId)/likes/\(post.postId)").removeValue()
        }
        
        // Increment/Decrement likes count
        if liked {
            POSTS_REF.child("\(post.postId)/likes").setValue(post.likes + 1)
        } else {
            POSTS_REF.child("\(post.postId)/likes").setValue(post.likes - 1)
        }
    }
    
    func getPostList() {
        POSTS_REF.observe(DataEventType.value, with: { (snapshot) in
            if let posts = snapshot.value as? Dictionary<String, Any> {
                if posts.count > 0 {
                    var postList: [Post] = [Post]()
                    for post in posts {
                        let postId = post.key
                        var likes = 0;
                        var imageUrl = ""
                        var caption = ""
                        var postingUserId = ""
                        if let dict = post.value as? Dictionary<String, Any> {
                            if let capt = dict["caption"] as? String {
                                caption = capt
                            }
                            
                            if let url = dict["imageUrl"] as? String {
                                imageUrl = url
                            }
                            
                            if let lks = dict["likes"] as? Int {
                                likes = lks
                            }
                            
                            // TODO: Add posting user name and image URL
                            if let userId = dict["postingUser"] as? String {
                                postingUserId = userId
                            }
                            
                            let post = Post(id: postId, caption: caption, imageUrl: imageUrl, likes: likes, postingUserId: postingUserId)
                            postList.append(post)
                        }
                    }
                    self.isPostsDownloadComplete = true
                    self.downloadCompleteDelegate?.handlePostsUpdated(posts: postList)
                }
            }
        })
    }
    
    func downloadUserDetailsOfUser(for post: Post, with completion: @escaping () -> Void) {
        USERS_REF.child(post.postUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userInfo = snapshot.value as? Dictionary<String, Any> {
                print(userInfo.count)
                guard let name = userInfo["name"] as? String, let photoUrl = userInfo["photoUrl"] as? String, let provider = userInfo["provider"] as? String else {
                    return
                }
                let usr = AppUser(userId: post.postUserId, userName: name, provider: provider, photoUrl: URL(string: photoUrl))
                post.postingUser = usr
                completion()
            }
            
        })
    }
}
