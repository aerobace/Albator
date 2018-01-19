//
//  ViewController.swift
//  albator
//
//  Created by Vincent Pacquet on 12/8/17.
//  Copyright © 2017 aerobace. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("Vince: ID found in keychain")
            DataService.ds.REF_USER_CURRENT.observe(.value) { (snapshot) in
                if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                    let key = snapshot.key
                    User.myUser = User(userKey: key, postData: userDict)
                }
            }
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Vince: Unable to authenticate with Facebook \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("Vince: User Canceled Facebook authentification")
            } else {
                print("Vince: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        var displayName: String = ""
        var fbemail: String = ""
        var photoURL: String = ""
        
        var img: UIImage = UIImage()
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Vince: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("Vince: Succesufully authenticated with Firebase")
                if let user = user {
                    if let _displayName = user.displayName {
                        displayName = _displayName
                    }
                    if let _email = user.email {
                        fbemail = _email
                    }
                    if let _photoURL = user.photoURL {
                        // Lets download the profile picture and store it
                        let url = _photoURL
                        let data = try? Data(contentsOf: url)
                        img = UIImage(data: data!)!
                        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                            let imgUid = NSUUID().uuidString
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/jpeg"
                            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                                if error != nil {
                                    print("Vince: Unable to upload Profile image to Firebase storage")
                                } else {
                                    print("Vince: Succesfully uploaded Profile image to Firebase storage")
                                    let downloadURL = metadata?.downloadURL()?.absoluteString
                                    if let url = downloadURL {
                                        photoURL = url
                                        let userData = ["provider": credential.provider, "displayName": displayName, "email": fbemail, "photoURL": photoURL]
                                        self.completeSignIn(id: user.uid, userData: userData)
                                    }
                                }
                            }
                        }
         
                    }
                    

                }
            }
        })
    }
    
    @IBAction func signInTapped(_ sender: Any) {

        if let email = emailField.text, let pwd = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Vince: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Vince: Unable to authenticate with Firebase using email")
                        } else {
                            print("Vince: Succesfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Vince: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

