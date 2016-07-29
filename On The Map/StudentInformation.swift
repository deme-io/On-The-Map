//
//  Student.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/24/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    
    // MARK: ===== Properties =====
    
    var firstName: String?
    var lastName: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
    }
    
    var title: String? {
        return "\(firstName!) \(lastName!)"
    }
    
    var subtitle: String? {
        if mediaURL != nil {
            if mediaURL!.rangeOfString("http://") == nil && mediaURL!.rangeOfString("https://") == nil {
                let newMediaURL = "http://" + mediaURL!
                return newMediaURL
            } else {
                return mediaURL
            }
        } else {
            return ""
        }
    }
    
    
    
    
    
    // MARK: ===== Init Method =====
    
    init(withDictionary: [String : AnyObject]) {
        firstName = withDictionary["firstName"] as? String
        lastName = withDictionary["lastName"] as? String
        mediaURL = withDictionary["mediaURL"] as? String
        latitude = withDictionary["latitude"] as? Double
        longitude = withDictionary["longitude"] as? Double
    }
}
