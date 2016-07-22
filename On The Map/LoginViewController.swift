//
//  LoginViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Properties
    var client = NetworkClient.sharedInstance()
    
    @IBOutlet weak var emailTextField: PaddedLoginTextField!
    @IBOutlet weak var passwordTextField: PaddedLoginTextField!
    
    
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

}

