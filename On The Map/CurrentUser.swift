//
//  CurrentUser.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/21/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation
import MapKit

class CurrentUser: NSObject, MKAnnotation {
    
    
    // MARK: ===== Properties =====
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var mediaURL: String?
    
    var sessionID : String?
    var userID : String?
    var facebookTokenString: String?
    
    
    
    
    
    // MARK: ===== MKAnnotion Protocol Properties =====
    
    var title: String?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    
    
    
    // MARK: ===== Singleton =====
    
    class func sharedInstance() -> CurrentUser {
        struct Singleton {
            static var sharedInstance = CurrentUser()
        }
        return Singleton.sharedInstance
    }
}