//
//  ListViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    
    // MARK: ===== View Methods =====
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Students.sharedInstance.isEmpty {
            loadData()
        }
        
    }
    
    
    
    func loadData() {
        NetworkClient.sharedInstance().loadStudents{ (errorString) in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentAlert("Reload Error", message: errorString!)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    
    
    
    
    // MARK: ===== IBAction Methods =====
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            loadData()
        } else {
            presentAlert("Network Failure", message: "Please check your internet connection")
        }
        
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    
    
    
    
    // MARK: ===== TableView Methods =====
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellResuseIdentifier = "customCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellResuseIdentifier) as! LocationTableViewCell
        
        let thisStudent = Students.sharedInstance[indexPath.row]

        cell.nameLabel.text = "\(thisStudent.firstName!) \(thisStudent.lastName!)"
        cell.urlLabel.text = thisStudent.subtitle!
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.sharedInstance.count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thisStudent = Students.sharedInstance[indexPath.row]
        guard var mediaURL = thisStudent.mediaURL else { return }
        
        if mediaURL.rangeOfString("http://") == nil && mediaURL.rangeOfString("https://") == nil {
            mediaURL = "http://" + mediaURL
        }
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
    }
    
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
}
