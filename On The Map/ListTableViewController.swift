//
//  ListViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var students = [Student]()
    
    //@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        
    }
    
    func reloadData() {
        NetworkClient.sharedInstance().loadStudents(self) { (data, errorString) in
            if errorString != nil {
                print(errorString)
            } else {
                self.students = data
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        reloadData()
    }
    
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // MARK: TableView Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellResuseIdentifier = "customCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellResuseIdentifier) as! LocationTableViewCell
        
        let thisStudent = students[indexPath.row]

        cell.nameLabel.text = "\(thisStudent.firstName!) \(thisStudent.lastName!)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thisStudent = students[indexPath.row]
        guard var mediaURL = thisStudent.mediaURL else { return }
        
        if mediaURL.rangeOfString("http://") == nil && mediaURL.rangeOfString("https://") == nil {
            mediaURL = "http://" + mediaURL
        }
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
    }
    
    
    
    
}
