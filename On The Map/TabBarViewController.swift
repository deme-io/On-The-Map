//
//  TabBarViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/25/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NetworkClient.sharedInstance().checkIfUserIsLoggedIn() == false {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginView")
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    
}
