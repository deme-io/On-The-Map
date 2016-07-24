//
//  CurrentUser.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/21/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation

class CurrentUser {
    var firstName: String?
    var lastName: String?
    var email: String?
    
    var username: String? = nil
    var password: String? = nil
    
    var sessionID : String? = nil
    var userID : String?
    var facebookTokenString: String?
    
    class func sharedInstance() -> CurrentUser {
        struct Singleton {
            static var sharedInstance = CurrentUser()
        }
        return Singleton.sharedInstance
    }
}