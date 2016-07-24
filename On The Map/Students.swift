//
//  Students.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/24/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation

class Students {
    var array = [Student]()
    
    class func sharedInstance() -> Students {
        struct Singleton {
            static var sharedInstance = Students()
        }
        return Singleton.sharedInstance
    }
}
