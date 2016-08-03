//
//  NetworkClient.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

//import Foundation
import UIKit
import MapKit

class NetworkClient: NSObject {
    
    // MARK: ===== Properties =====
    static var sharedInstance = NetworkClient()
    
    var session = NSURLSession.sharedSession()
    var currentUser = CurrentUser.sharedInstance()
    //var studentsArray = Students.sharedInstance
    
    
    
    
    
    // MARK: ===== Authentication Sequence =====
    
    func authenticateUser(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        getSessionAndUserID { (success, sessionID, errorString) in
            completionHandlerForAuth(success: success, errorString: errorString)
        }
    }
    
    
    
    private func getSessionAndUserID(completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(FBSDKAccessToken.currentAccessToken().tokenString)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        } else {
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(currentUser.email!)\", \"password\": \"\(currentUser.password!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func forwardError(errorString: String) {
                completionHandlerForSession(success: false, sessionID: nil, errorString: "\(errorString)")
            }
            
            guard (error == nil) else {
                forwardError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                forwardError("Your request returned a status code other than 2xx!")
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
            }
            
            guard let data = data else {
                forwardError("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse JSON data: \(newData)")
            }
            
            if let parsedSession = parsedResult["session"] as? NSDictionary {
                self.currentUser.sessionID = parsedSession["id"]! as? String
            }
            
            if let parsedAccount = parsedResult["account"] as? NSDictionary {
                self.currentUser.userID = parsedAccount["key"]! as? String
            }
            
            self.getUserInfo()
            completionHandlerForSession(success: true, sessionID: self.currentUser.sessionID, errorString: "\(error)")
        }
        task.resume()
    }
    
    
    private func getUserInfo() {
        if let userId = currentUser.userID {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userId)")!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    return
                }
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! [String : AnyObject]
                } catch {
                    print("Could not parse JSON data: \(newData)")
                }
                
                if let userInfo = parsedResult["user"] as? NSDictionary {
                    self.currentUser.firstName = userInfo["first_name"]! as? String
                    self.currentUser.lastName = userInfo["last_name"]! as? String
                    self.currentUser.email = userInfo["email"]!["address"]! as? String
                }
            }
            task.resume()
        }
    }
    
    
    
    
    
    // MARK: ===== Log In / Log Out Methods =====
    
    func logout() {
        currentUser.sessionID = nil
        FBSDKLoginManager().logOut()
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            //let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func checkIfUserIsLoggedIn() -> Bool {
        if (FBSDKAccessToken.currentAccessToken() != nil) || currentUser.sessionID != nil {
            if FBSDKAccessToken.currentAccessToken()?.tokenString != nil {
                currentUser.facebookTokenString = FBSDKAccessToken.currentAccessToken().tokenString
                getSessionAndUserID({ (success, sessionID, errorString) in
                    if !success {
                        print(errorString)
                    }
                })
            }
            return true
        } else {
            return false
        }
    }
    
    
    private func presentAlertView(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
    }
    
    
    
    
    
    
    // MARK: ===== Data Methods =====
    
    func loadStudents(completionHandlerForAuth: (errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(Constants.Parse.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.HTTPMethod = "GET"

        let task = session.dataTaskWithRequest(request) { data, response, taskerror in
            func forwardError(errorString: String) {
                completionHandlerForAuth(errorString: errorString)
            }
            
            
            guard (taskerror == nil) else {
                print(taskerror?.localizedDescription)
                forwardError((taskerror?.localizedDescription)!)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                forwardError("Your request returned a status code of \((response as? NSHTTPURLResponse)!.statusCode)")
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
            }
            
            guard let data = data else {
                forwardError("No data was returned by the request!")
                return
            }
            
            
            var parsedResult: [String: AnyObject]
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String : AnyObject]
            } catch {
                completionHandlerForAuth(errorString: taskerror?.localizedDescription)
                return
            }
            
            guard let downloadedStudents = parsedResult["results"] as? NSArray else {
                completionHandlerForAuth(errorString: "Could not load data")
                return
            }
            
            Students.sharedInstance = []
            
            for newStudent in downloadedStudents {
                let studentValues = ["firstName": newStudent["firstName"],
                                     "lastName": newStudent["lastName"],
                                     "mediaURL": newStudent["mediaURL"],
                                     "latitude": newStudent["latitude"],
                                     "longitude": newStudent["longitude"]]
                let student = StudentInformation(withDictionary: studentValues as! [String : AnyObject])
                Students.sharedInstance.append(student)
            }
            
            completionHandlerForAuth(errorString: taskerror?.localizedDescription)
        }
        task.resume()
    }
    
    
    func postUserInfo(completionHandlerForPost: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.Parse.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(NSUUID().UUIDString)\", \"firstName\": \"\(currentUser.firstName!)\", \"lastName\": \"\(currentUser.lastName!)\",\"mapString\": \"\(currentUser.title!)\", \"mediaURL\": \"\(currentUser.mediaURL!)\",\"latitude\": \(currentUser.coordinate.latitude), \"longitude\": \(currentUser.coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandlerForPost(success: false, errorString: error?.localizedDescription)
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            completionHandlerForPost(success: true, errorString: nil)
        }
        task.resume()
    }
    
}
