//
//  ListViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    //@IBOutlet weak var tableView: UITableView!
    var data = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkClient.sharedInstance().getStudentLocations(self) { (data, errorString) in
            if errorString == nil {
                self.data = (data["results"] as! NSArray) as Array
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.reloadData()
            }
        }
        
    }
    
    func reloadData () {
        tableView.reloadData()
    }
    
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        reloadData()
    }
    
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // MARK: TableView Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellResuseIdentifier = "customCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellResuseIdentifier) as! LocationTableViewCell
        
        let user = data[indexPath.row] as! NSDictionary
        
        cell.nameLabel.text = "\(user["firstName"]!) \(user["lastName"]!)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = data[indexPath.row] as! NSDictionary
        var mediaURL = user["mediaURL"] as! String
        
        if mediaURL.rangeOfString("http://") == nil && mediaURL.rangeOfString("https://") == nil {
            mediaURL = "http://" + mediaURL
        }
        print(mediaURL)
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
    }
    
    
    
    
}
