//
//  User.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/21/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation

class User {
    var firstName: String?
    var lastName: String?
    
    var username: String? = nil
    var password: String? = nil
    
    var sessionID : String? = nil
    var userID : String?
    
    class func sharedInstance() -> User {
        struct Singleton {
            static var sharedInstance = User()
        }
        return Singleton.sharedInstance
    }
}