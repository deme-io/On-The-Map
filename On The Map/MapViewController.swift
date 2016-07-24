//
//  MapViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/19/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var data = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        reloadData()
    }
    
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    func reloadData () {
        NetworkClient.sharedInstance().getStudentLocations(self) { (data, errorString) in
            if errorString == nil {
                self.data = (data["results"] as! NSArray) as Array
            }
            dispatch_async(dispatch_get_main_queue()) {
                //self.tableView.reloadData()
            }
        }
        
    }
    
}
