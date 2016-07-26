//
//  Student.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/24/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation
import MapKit

class Student: NSObject, MKAnnotation {
    var firstName: String?
    var lastName: String?
    
    var mapString: String?
    var mediaURL: String?
    
    var objectID: String?
    var uniqueKey: String?
    
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
                mediaURL = "http://" + mediaURL!
            }
            //UIApplication.sharedApplication().openURL(NSURL(string: mediaURL!)!)
            return mediaURL!
        } else {
            return ""
        }
    }
    
    init(firstName: String, lastName: String, mapString: String, mediaURL: String, objectID: String, uniqueKey: String, latitude: Double, longitude: Double) {
        super.init()
        
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectID = objectID
        self.uniqueKey = uniqueKey
        self.latitude = latitude
        self.longitude = longitude
        //self.coordinate = coordinate
    }
}
