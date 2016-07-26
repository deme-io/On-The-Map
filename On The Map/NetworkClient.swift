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
    
    var session = NSURLSession.sharedSession()
    var currentUser = CurrentUser.sharedInstance()
    var students = [Student]()
    //var results = []
    
    
    func authenticateUser(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        getSessionAndUserID { (success, sessionID, errorString) in
            if success {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
    
    // MARK: Network Methods
    
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
            if error != nil { // Handle error…
                return
            }
            //let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func checkIfUserIsLoggedIn() -> Bool {
        if (FBSDKAccessToken.currentAccessToken() != nil) || currentUser.sessionID != nil {
            if FBSDKAccessToken.currentAccessToken().tokenString != nil {
                currentUser.facebookTokenString = FBSDKAccessToken.currentAccessToken().tokenString
            }
            return true
        } else {
            return false
        }
    }
    
    func loadStudents(hostViewController: UIViewController, completionHandlerForAuth: (data: [Student], errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue(Constants.Parse.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = session.dataTaskWithRequest(request) { data, response, taskerror in
            if taskerror != nil { // Handle error...
                //completionHandlerForAuth(data: [], errorString: taskerror?.localizedDescription)
                return
            }
            
            var parsedResult: [String: AnyObject]
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String : AnyObject]
            } catch {
                print("Could not parse JSON data: \(data!)")
                //completionHandlerForAuth(data: nil, errorString: taskerror?.localizedDescription)
                return
            }
            
            let downloadedStudents = parsedResult["results"] as! NSArray
            
            for newStudent in downloadedStudents {
                let student: Student = Student(firstName: newStudent["firstName"] as! String, lastName: newStudent["lastName"] as! String, mapString: newStudent["mapString"] as! String, mediaURL: newStudent["mediaURL"] as! String, objectID: newStudent["objectId"] as! String, uniqueKey: newStudent["uniqueKey"] as! String, latitude: newStudent["latitude"] as! Double, longitude: newStudent["longitude"] as! Double)
                
                self.students.append(student)
            }
            
            completionHandlerForAuth(data: self.students, errorString: taskerror?.localizedDescription)
        }
        task.resume()
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
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
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
            
            completionHandlerForSession(success: true, sessionID: self.currentUser.sessionID, errorString: "\(error)")
        }
        task.resume()
    }

    
    
    // TODO: Finish taskForPOSTMethod
    // MARK: Task for POST Method
    
    private func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        //parametersWithApiKey[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parametersWithApiKey, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    private func udacityURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.UdacityURLS.ApiScheme
        components.host = Constants.UdacityURLS.ApiHost
        components.path = Constants.UdacityURLS.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    
    class func sharedInstance() -> NetworkClient {
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        return Singleton.sharedInstance
    }
    
}
