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
    
    var students = [Student]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        loadData()
        mapView.addAnnotations(students)
        mapView.showAnnotations(students, animated: true)
    }
    
    func loadData() {
        let temp = students
        NetworkClient.sharedInstance().loadStudents(self) { (data, errorString) in
            if errorString != nil {
                print(errorString)
            } else {
                self.students = []
                self.students = data
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.removeAnnotations(temp)
                    self.mapView.addAnnotations(self.students)
                })
            }
        }
    }
    
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        loadData()
    }
    
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        NetworkClient.sharedInstance().logout()
        let controller = storyboard!.instantiateViewControllerWithIdentifier("loginView") as! LoginViewController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Student {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                //view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                view.animatesDrop = true
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let link = view.annotation?.subtitle else { return }
        
        UIApplication.sharedApplication().openURL(NSURL(string: link!)!)
    }
}
