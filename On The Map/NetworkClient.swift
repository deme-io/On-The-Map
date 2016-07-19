//
//  NetworkClient.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation

class NetworkClient {
    var session = NSURLSession.sharedSession()
    
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil
}
