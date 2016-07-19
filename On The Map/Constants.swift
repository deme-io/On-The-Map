//
//  Constants.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Udacity {
        
        struct URLS {
            // MARK: Udacity.com signup page URL
            static let udacitySignupURLString = "https://www.udacity.com/account/auth#!/signup"
            
            // MARK: URLs
            static let ApiScheme = "https"
            static let ApiHost = "udacity.com"
            static let ApiPath = "/api"
            static let AuthorizationURL : String = "https://www.themoviedb.org/authenticate/"
        }
        
        struct Methods {
            static let getSessionID = "/session"
        }
        
    }
    
}