//
//  LoginViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: Properties
    var client = NetworkClient.sharedInstance()
    
    @IBOutlet weak var emailTextField: PaddedLoginTextField!
    @IBOutlet weak var passwordTextField: PaddedLoginTextField!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFacebook()
        facebookLoginButton.delegate = self
    }
    
    
    // MARK: Action Methods
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        client.username = emailTextField.text!
        client.password = passwordTextField.text!
        
        client.authenticateWithViewController(self) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("navigationView") as! UINavigationController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func signupButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Constants.UdacityURLS.UdacitySignupURL)!)
    }
    
    
    func configureFacebook()
    {
        facebookLoginButton.readPermissions = ["public_profile", "email"];
        facebookLoginButton.delegate = self
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name"]).startWithCompletionHandler { (connection, result, error) -> Void in
            self.client.firstName = (result.objectForKey("first_name") as? String)!
            self.client.lastName = (result.objectForKey("last_name") as? String)!
            }
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

}

