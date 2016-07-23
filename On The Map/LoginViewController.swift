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
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //facebookLoginButton.readPermissions = ["public_profile", "email"];
        //facebookLoginButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            facebookLoginButton.setTitle("Sign out of Facebook", forState: UIControlState.Normal)
        } else {
            facebookLoginButton.setTitle("Sign in with Facebook", forState: UIControlState.Normal)
        }
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
    
    
    @IBAction func facebookLoginButtonPressed(sender: AnyObject) {
        
        let login = FBSDKLoginManager()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            facebookLoginButton.setTitle("Sign in with Facebook", forState: UIControlState.Normal)
            login.logOut()
        } else {
            login.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if result.isCancelled {
                    print("Cancelled")
                } else {
                    print("Logged in")
                    FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email"]).startWithCompletionHandler { (connection, result, error) -> Void in
                        self.client.firstName = (result.objectForKey("first_name") as? String)!
                        self.client.lastName = (result.objectForKey("last_name") as? String)!
                        self.client.email = (result.objectForKey("email") as? String)!
                        
                        print(self.client.firstName!)
                        print(self.client.lastName!)
                        print(self.client.email!)
                    }
                }
            }
            facebookLoginButton.setTitle("Sign out of Facebook", forState: UIControlState.Normal)
        }
        
        
        
    }
    
    
    // MARK: Facebook Loging Methods
    
    
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

