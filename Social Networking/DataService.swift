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
    var postList: [Post] = [Post]()
    
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
                    self.postList.removeAll()
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
                            
                            if let userId = dict["postingUser"] as? String {
                                postingUserId = userId                                
                            }                                                        
                            
                            let post = Post(id: postId, caption: caption, imageUrl: imageUrl, likes: likes, postingUserId: postingUserId)
                            self.postList.append(post)
                        }
                    }
                    self.getPostingUserForDownloadedPosts()
                }
            }
        })
    }
    
    func getPostingUserForDownloadedPosts() {
        var count = 0
        for post in self.postList {
            USERS_REF.child(post.postUserId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let info = snapshot.value as? Dictionary<String, Any> {
                    guard let name = info["name"] as? String, let photoUrl = info["photoUrl"] as? String, let provider = info["provider"] as? String else {
                        print("Error getting user details for post!")
                        return
                    }
                    
                    let usr = AppUser(userId: post.postUserId, userName: name, provider: provider, photoUrl: URL(string: photoUrl))
                    post.postingUser = usr
                    count += 1
                }
                
                if count == self.postList.count {
                    self.isPostsDownloadComplete = true
                    self.downloadCompleteDelegate?.handlePostsUpdated(posts: self.postList)
                }
            })
        }
        
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
    
    func createNewPost(post: Post, img: UIImage?, completion: @escaping () -> Void) {
        guard let usr = appUser else {
            print("Error! User not initialized!")
            return
        }
        
        if let postImage = img {
            let imgData = UIImagePNGRepresentation(postImage)
            let imgReference = STORAGE_REFERENCE.child("\(post.postId).jpeg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imgReference.putData(imgData!, metadata: metadata, completion: { (storageMd, error) in
                guard error == nil else { return }
                imgReference.downloadURL(completion: { (url, error) in
                    guard error == nil else { return }
                    if let imgUrl = url {
                        post.imageUrl = imgUrl.absoluteString
                        let postDict = ["caption": post.caption, "imageUrl": post.imageUrl, "likes": post.likes, "postingUser":post.postUserId] as [String : Any]
                        POSTS_REF.child(post.postId).updateChildValues(postDict)
                        USERS_REF.child("\(usr.userId)/posts").updateChildValues([post.postId: true])
                        completion()                        
                    }
                })
                
            }).resume()
        } else {
            let postDict = ["caption": post.caption, "imageUrl": post.imageUrl, "likes": post.likes, "postingUser":post.postUserId] as [String : Any]
            POSTS_REF.child(post.postId).updateChildValues(postDict)
            USERS_REF.child("\(usr.userId)/posts").updateChildValues([post.postId: true])
            completion()
        }
    }    
    
}
