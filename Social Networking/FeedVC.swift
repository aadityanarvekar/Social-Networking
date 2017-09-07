//
//  FeedVC.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/17/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FBSDKLoginKit

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostsDownloadComplete {
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var addImage: UIImageView!
    private var imagePicker = UIImagePickerController()    
    private var posts: [Post] = [Post]()
    @IBOutlet weak var loggedInUserImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleDismissKeyboard()
        
        feedTableView.dataSource = self
        feedTableView.delegate = self
        
        imagePicker.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageForPost))
        addImage.addGestureRecognizer(tapGesture)
        
        DataService.shared.downloadCompleteDelegate = self
        DataService.shared.getPostList()
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let imgUrl = DataService.shared.appUser?.photoUrl, imgUrl != DEFAULT_PROFILE_IMAGE {
            URLSession.shared.dataTask(with: imgUrl, completionHandler: { (data, response, err) in
                guard err == nil, data != nil else {
                    print("Error retrieving image for logged in user. Error: \(err.debugDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.loggedInUserImg.image = UIImage(data: data!)
                }
            }).resume()
        }
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        let result = KeychainWrapper.standard.removeAllKeys()
        if !result {
            print("Error deleting UID key from keychain using KeyChainWrapper")
        }
        
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print("Error occured when signing out of Firebase: \(err.localizedDescription)")
        }
        
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
        }
        
        DataService.shared.appUser = nil
        
        DataService.shared.isPostsDownloadComplete = false
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func createPostBtnTapped(_ sender: Any) {
        
    }
    
    func selectImageForPost() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: Table View DS and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedTableViewCell {
            cell.configureFeedCell(post: posts[indexPath.row])
            cell.postLikedDelegate = self
            return cell
        } else {
            print("Incorrect cell dequeued")
            return UITableViewCell()
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addImage.image = selectedImage
            addImage.layer.cornerRadius = addImage.frame.size.width / 2.0
            addImage.layer.masksToBounds = true
            addImage.contentMode = .scaleAspectFill
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Data Download complete protocol
    func handlePostsUpdated(posts: [Post]) {
        print("Data download complete")
        self.posts = posts
        feedTableView.reloadData()
    }
    
}

// MARK: Extension/Protocol Implementations

extension FeedVC: UserDetailsDownloadComplete {
    func handleUserDetailsDownloadComplete(user: AppUser) {
        if DataService.shared.isPostsDownloadComplete {
            feedTableView.reloadData()
        }
    }
}


extension FeedVC: PostLiked {
    func handleUserLikedPost(post: Post, liked: Bool) {
        DataService.shared.toggleLikeStatus(for: post, liked: liked)
    }
}
