//
//  Constants.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/17/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import Foundation
import Firebase

let KEYCHAIN_KEY = "KEYCHAIN-USER-KEY"

// MARK: Firebase References
let BASE: DatabaseReference = Database.database().reference()
let POSTS_REF = BASE.child("posts")
let USERS_REF = BASE.child("users")
		
// MARK: Default Profile Image
let DEFAULT_PROFILE_IMAGE = URL(string: "https://firebasestorage.googleapis.com/v0/b/social-application-84c74.appspot.com/o/Profile.png?alt=media&token=0319267f-185a-4f9e-a23e-e7ec6e2b1df0")!
