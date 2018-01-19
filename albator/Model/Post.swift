//
//  Post.swift
//  albator
//
//  Created by Vincent Pacquet on 1/10/18.
//  Copyright © 2018 aerobace. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageURL: String!
    private var _profileURL: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _userKey: String!
    private var _postsRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }

    var profileURL: String {
        return _profileURL
    }

    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }

    var userKey: String {
        return _userKey
    }

    init(caption: String, imageURL: String, profileURL: String, likes: Int) {
        self._caption = caption
        self._imageURL = imageURL
        self._profileURL = profileURL
        self._likes = likes
    }
    
    init(postKey: String, userKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        self._userKey = userKey
        self._caption = ""
        self._imageURL = ""
        self._profileURL = ""
        self._likes = 0
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }

        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }

        if let profileURL = postData["profileURL"] as? String {
            self._profileURL = profileURL
        }

        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        _postsRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postsRef.child("likes").setValue(_likes)
    }
}
