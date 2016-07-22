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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
    }
    
}
