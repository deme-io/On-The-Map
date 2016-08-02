//
//  Reachability.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/25/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//



// This solution is from StackOverflow.com



import Foundation
import SystemConfiguration

public class Reachability {
    
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        
        // For Swift 3, replace the last two lines by
        // let isReachable = flags.contains(.reachable)
        // let needsConnection = flags.contains(.connectionRequired)
        
        
        return (isReachable && !needsConnection)
    }
    
}