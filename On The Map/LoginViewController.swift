//
//  LoginViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    // MARK: Properties
    var client = NetworkClient.sharedInstance()
    var currentUser = CurrentUser.sharedInstance()
    
    @IBOutlet weak var emailTextField: PaddedLoginTextField!
    @IBOutlet weak var passwordTextField: PaddedLoginTextField!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var visualBlur: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoadingVisual()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        if client.checkIfUserIsLoggedIn() == true {
            authenticate()
        }
        
    }
    
    
    
    
    // MARK: Loading Visual Methods
    func startLoadingVisual() {
        visualBlur.hidden = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    
    func stopLoadingVisual() {
        visualBlur.hidden = true
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    
    
    
    
    // MARK: IBAction Methods
    @IBAction func loginButtonPressed(sender: AnyObject) {
        logIn()
    }

    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Constants.UdacityURLS.SignupURL)!)
    }
    
    
    @IBAction func facebookLoginButtonPressed(sender: AnyObject) {
        startLoadingVisual()
        
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
                    FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email"]).startWithCompletionHandler { (connection, result, error) -> Void in
                        self.currentUser.firstName = (result.objectForKey("first_name") as? String)!
                        self.currentUser.lastName = (result.objectForKey("last_name") as? String)!
                        self.currentUser.email = (result.objectForKey("email") as? String)!
                        self.currentUser.facebookTokenString = FBSDKAccessToken.currentAccessToken().tokenString
                        
                        self.authenticate()
                    }
                }
            }
            facebookLoginButton.setTitle("Sign out of Facebook", forState: UIControlState.Normal)
        }
    }
    
    
    
    
    
    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        logIn()
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    
    // MARK: Network Methods
    func authenticate() {
        startLoadingVisual()
        if Reachability.isConnectedToNetwork() {
            client.authenticateUser(self) { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.stopLoadingVisual()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentAlert("Login Error", message: "Please check your email and password")
                        self.stopLoadingVisual()
                        //return
                    }
                }
                
            }
        } else {
            presentAlert("Network Failure", message: "Please check your internet connection")
        }
        
    }
    
    
    func logIn() {
        if (isValidEmail(emailTextField.text!) && passwordTextField.text != "") {
            currentUser.email = emailTextField.text!
            currentUser.password = passwordTextField.text!
            authenticate()
        } else {
            presentAlert("Login Error", message: "Please enter a valid email and password")
        }
    }
    
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Logic Methods
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    
    
    
    
    // MARK: Facebook Delegate Methods
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

