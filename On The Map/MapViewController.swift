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
    
    // MARK: ===== Properties =====
    
    let client = NetworkClient.sharedInstance()
    var annotationsArray = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    // MARK: ===== View Methods =====
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if Students.sharedInstance.isEmpty {
            reloadMapData()
        } else {
            loadMapWithAnnotations()
        }
    }
    
    
    
    
    
    
    // MARK: ===== Data Methods =====
    
    func loadMapWithAnnotations() {
        mapView.removeAnnotations(annotationsArray)
        self.annotationsArray = []
        for newStudent in Students.sharedInstance {
            let annotation = MKPointAnnotation()
            annotation.title = "\(newStudent.firstName!) \(newStudent.lastName!)"
            annotation.coordinate = newStudent.coordinate
            annotation.subtitle = newStudent.subtitle!
            
            self.annotationsArray.append(annotation)
        }
        mapView.addAnnotations(annotationsArray)
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    
    func reloadMapData() {
        client.loadStudents { (errorString) in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentAlert("Reload Error", message: errorString!)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadMapWithAnnotations()
                })
            }
        }
    }
    
    
    
    
    
    
    // MARK: ===== IBAction Methods =====
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            reloadMapData()
        } else {
            presentAlert("Network Failure", message: "Please check your internet connection")
        }
        
        
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: ===== MapView Methods =====
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            view.animatesDrop = false
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let link = view.annotation?.subtitle else { return }
        UIApplication.sharedApplication().openURL(NSURL(string: link!)!)
    }
}
