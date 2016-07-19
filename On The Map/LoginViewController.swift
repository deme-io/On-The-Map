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
    
    @IBOutlet weak var emailTextField: PaddedLoginTextField!
    @IBOutlet weak var passwordTextField: PaddedLoginTextField!
    
    
    // MARK: Action Methods
    @IBAction func loginButtonPressed(sender: AnyObject) {
    }

    @IBAction func signupButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Constants.URLS.udacitySignupURLString)!)
    }

}

