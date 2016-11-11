//
//  Post.swift
//  Travellr
//
//  Created by Manish Gehani on 11/5/16.
//  Copyright © 2016 Manish Gehani. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _userName: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var userName: String {
        return _userName
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imgUrl: String?, usrName: String) {
        self._postDescription = description
        self._imageUrl = imgUrl
        self._userName = usrName
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {                    //exact same names as on Firebase
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike == true {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
}
