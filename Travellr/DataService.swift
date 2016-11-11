//
//  DataService.swift
//  Travellr
//
//  Created by Manish Gehani on 11/4/16.
//  Copyright © 2016 Manish Gehani. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService()
    private var _REF_BASE = FIRDatabase.database().reference()
    private var _REF_POSTS = FIRDatabase.database().referenceWithPath("posts")
    private var _REF_USERS = FIRDatabase.database().referenceWithPath("users")
    
    var REF_DB: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = REF_USERS.child(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.child(uid).setValue(user)
        
        
    }
    
}