//
//  ListViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    
}
