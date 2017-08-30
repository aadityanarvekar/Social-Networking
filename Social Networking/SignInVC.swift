//
//  ViewController.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/11/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import UITextField_Shake
import SwiftKeychainWrapper
import EZLoadingActivity

class SignInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var emailAddressTxtField: InsetTextField!
    @IBOutlet weak var passwordTxtField: InsetTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddressTxtField.delegate = self
        passwordTxtField.delegate = self
//        EZLoadingActivity.Settings.BackgroundColor = UIColor(colorLiteralRed: 1, green: 148, blue: 160, alpha: 0)
//        EZLoadingActivity.Settings.TextColor = UIColor.white
        self.handleDismissKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let uIdString = KeychainWrapper.standard.string(forKey: KEYCHAIN_KEY) {
            performSegue(withIdentifier: "FeedVC", sender: uIdString)
        } else {
            if (FBSDKAccessToken.current() != nil) {
                print("User is already authenticated via FB")
                if let tokenString = FBSDKAccessToken.current().tokenString {
                    let fbCredential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                    loginWithFireBaseUsingCredential(credential: fbCredential)
                } else {
                    print("Problem with FB Access Token")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func facebookAuthenticationBtnTapped(_ sender: Any) {
        print("Authenticate using FB")
        loginUsingFBAuthentication()
    }
    
    private func loginUsingFBAuthentication() {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            guard error == nil else {
                print("Failed to login: \(error.debugDescription)")
                return
            }
            if let cancelled = result?.isCancelled {
                if !cancelled {
                    EZLoadingActivity.show("Authenticating...", disableUI: true)
                    if let tokenString = FBSDKAccessToken.current().tokenString {
                        let fbCredential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                        self.loginWithFireBaseUsingCredential(credential: fbCredential)
                    } else {
                        print("Problem with getting access token")
                        EZLoadingActivity.hide(false, animated: true)
                    }
                } else {
                    print("User denied FB authentication request")
                    EZLoadingActivity.hide()
                }
            }
        }
    }
    
    private func loginWithFireBaseUsingCredential(credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            guard error == nil else {
                print("Error logging in with FB: \(error.debugDescription)")
                EZLoadingActivity.hide()
                return
            }
            print("Logged in successfully with Firebase: \(user?.uid ?? "DEFAULT")")
            if let user = user {
                //self.saveUserToKeychain(withId: uid, provider: credential.provider)
                self.saveUserToKeychain(user: user, provider: credential.provider)
            }
        })
    }
    
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        if let email = emailAddressTxtField.text, email.characters.count > 0, let password = passwordTxtField.text, password.characters.count >= 6 {
            EZLoadingActivity.show("Authenticating...", disableUI: true)
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("User logged in to Firebase with email & password: \(user?.uid ?? "DEFAULT")")
                    if let usr = user, let provider = user?.providerID {
                        //self.saveUserToKeychain(withId: uid, provider: provider)
                        self.saveUserToKeychain(user: usr, provider: provider)
                    }
                } else {
                    let errCode: AuthErrorCode = AuthErrorCode(rawValue: error!._code)!
                    if errCode == .wrongPassword || errCode == .invalidEmail {
                        EZLoadingActivity.hide(false, animated: true)
                        print("Incorrect email and password provided")
                        self.emailAddressTxtField.shake()
                        self.passwordTxtField.shake()
                        if let err = error?.localizedDescription {
                            self.presentAlert(withMessage: err)
                        }
                    }
                    
                    if errCode == .userNotFound {
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                //let errorCode: AuthErrorCode = AuthErrorCode(rawValue: error!._code)!
                                if let err = error?.localizedDescription {
                                    EZLoadingActivity.hide(false, animated: true)
                                    self.presentAlert(withMessage: err)
                                }
                            } else {
                                print("User with email and password authentication created: \(user?.uid ?? "NO USER UID")")
                                if let usr = user, let provider = user?.providerID {
                                    //self.saveUserToKeychain(withId: uid, provider: provider)
                                    self.saveUserToKeychain(user: usr, provider: provider)
                                }
                            }
                        })
                    }
                }
            })
        } else {
            print("Email and Password needed to login")
            if emailAddressTxtField.text?.characters.count == 0 {
                emailAddressTxtField.shake()
            }
            
            if (passwordTxtField.text?.characters.count)! < 6 {
                passwordTxtField.shake()
            }
        }
    }
    
    private func saveUserToKeychain(withId id: String, provider: String) {
        let result = KeychainWrapper.standard.set(id, forKey: KEYCHAIN_KEY)
        print("User saved to keychain: \(result)")
        
        if let _ = emailAddressTxtField.text, let _ = passwordTxtField.text {
            emailAddressTxtField.text = ""
            passwordTxtField.text = ""
        }
        let uData: Dictionary<String, String> = ["provider" : provider]
        DataService.shared.createFirebaseDBUser(with: id, userData: uData)
        EZLoadingActivity.hide(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.performSegue(withIdentifier: "FeedVC", sender: id)
        }
    }
    
    private func saveUserToKeychain(user: User, provider: String) {
        // Create App User
        let appUser = AppUser(userId: user.uid, userName: user.displayName, provider: provider, photoUrl: user.photoURL)
//        DataService.shared.appUser = appUser
        
        let result = KeychainWrapper.standard.set(user.uid, forKey: KEYCHAIN_KEY)
        print("User saved to keychain: \(result)")
        
        if let _ = emailAddressTxtField.text, let _ = passwordTxtField.text {
            emailAddressTxtField.text = ""
            passwordTxtField.text = ""
        }
        
        let uData: Dictionary<String, String> = ["provider" : appUser.provider, "name" : appUser.userName, "photoUrl" : appUser.photoUrl.absoluteString]
        DataService.shared.createFirebaseDBUser(with: user.uid, userData: uData)
        EZLoadingActivity.hide(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.performSegue(withIdentifier: "FeedVC", sender: user.uid)
        }
    }
    
    private func presentAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Text Field Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            passwordTxtField.becomeFirstResponder()
        } else {
            passwordTxtField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""        
        return true
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FeedVC, let userId = sender as? String {
            DataService.shared.userDetailsDownloadCompleteDelegate = destination
            DataService.shared.getUserInformation(uID: userId)
        }
    }

}

