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
    var currentUser = CurrentUser.sharedInstance()
    
    @IBOutlet weak var emailTextField: PaddedLoginTextField!
    @IBOutlet weak var passwordTextField: PaddedLoginTextField!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var visualBlur: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //facebookLoginButton.readPermissions = ["public_profile", "email"];
        //facebookLoginButton.delegate = self
        loading()
        
        if facebookTokenVerify() == true {
            currentUser.facebookTokenString = FBSDKAccessToken.currentAccessToken().tokenString
            loading()
            authenticate()
        }
        visualBlur.hidden = true
        activityIndicator.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if facebookTokenVerify() == true {
            loading()
            facebookLoginButton.setTitle("Sign out of Facebook", forState: UIControlState.Normal)
        } else {
            facebookLoginButton.setTitle("Sign in with Facebook", forState: UIControlState.Normal)
        }
        
        
    }
    
    func loading() {
        visualBlur.hidden = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func facebookTokenVerify() -> Bool {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: Action Methods
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        currentUser.username = emailTextField.text!
        currentUser.password = passwordTextField.text!
        loading()
        
        authenticate()
    }

    @IBAction func signupButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Constants.UdacityURLS.SignupURL)!)
    }
    
    
    @IBAction func facebookLoginButtonPressed(sender: AnyObject) {
        loading()
        
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
                        self.currentUser.firstName = (result.objectForKey("first_name") as? String)!
                        self.currentUser.lastName = (result.objectForKey("last_name") as? String)!
                        self.currentUser.email = (result.objectForKey("email") as? String)!
                        self.currentUser.facebookTokenString = FBSDKAccessToken.currentAccessToken().tokenString
                        
                        print(self.currentUser.firstName!)
                        print(self.currentUser.lastName!)
                        print(self.currentUser.email!)
                        print(FBSDKAccessToken.currentAccessToken().tokenString)
                        
                        self.authenticate()
                    }
                }
            }
            facebookLoginButton.setTitle("Sign out of Facebook", forState: UIControlState.Normal)
        }
    }
    
    
    func authenticate() {
        client.authenticateWithViewController(self) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarView") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: Facebook Loging Methods
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name"]).startWithCompletionHandler { (connection, result, error) -> Void in
            self.currentUser.firstName = (result.objectForKey("first_name") as? String)!
            self.currentUser.lastName = (result.objectForKey("last_name") as? String)!
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

