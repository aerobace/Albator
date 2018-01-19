//
//  User.swift
//  albator
//
//  Created by Vincent Pacquet on 1/10/18.
//  Copyright © 2018 aerobace. All rights reserved.
//

import Foundation
import Firebase

class User {
    static var myUser = User()
    
    private var _displayName: String!
    private var _imageURL: String!
    private var _email: String!
    private var _provider: String!
    private var _userKey: String!
    private var _usersRef: DatabaseReference!
    
    var displayName: String {
        return _displayName
    }
    
    var imageURL: String {
        return _imageURL
    }

    var email: String {
        return _email
    }
    
    var provider: String {
        return _provider
    }
    
    var userKey: String {
        return _userKey
    }
    
    init() {
        self._displayName = ""
        self._imageURL = ""
        self._email = ""
        self._provider = ""
        self._userKey = ""
    }
    
    init(displayname: String, imageURL: String, email: String, provider: String) {
        self._displayName = displayname
        self._imageURL = imageURL
        self._email = email
        self._provider = provider
    }
    
    init(userKey: String, postData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let displayname = postData["displayName"] as? String {
            self._displayName = displayname
        }

        if let displayname = postData["email"] as? String {
            self._email = displayname
        }
        
        if let provider = postData["provider"] as? String {
            self._provider = provider
        }

        if let imageURL = postData["photoURL"] as? String {
            self._imageURL = imageURL
        }
        
        _usersRef = DataService.ds.REF_USERS.child(_userKey)
    }
    
}

