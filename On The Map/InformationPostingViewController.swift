//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Demetrius Henry on 7/26/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    // MARK: ===== Properties =====
    
    let client = NetworkClient.sharedInstance()
    let currentUser = CurrentUser.sharedInstance()
    
    @IBOutlet weak var whereAreYouStudyingLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var loadingView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        urlTextField.delegate = self
        mapView.delegate = self
        mapView.hidden = true
        submitButton.hidden = true
        urlTextField.hidden = true
        stopLoadingVisual()
    }
    
    
    
    
    
    
    // MARK: ===== IBAction Methods =====
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func findOnTheMapPressed(sender: AnyObject) {
        shouldGeocode()
    }
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        if urlTextField.text == "" {
            presentAlert("URL Missing", message: "Please enter a url")
        } else {
            currentUser.mediaURL = urlTextField.text
            client.postUserInfo({ (success, errorString) in
                if !success {
                    self.presentAlert("Error", message: errorString!)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            })
        }
    }
    
    
    
    
    
    
    // MARK: ===== Visual Methods =====
    
    func startLoadingVisual() {
        loadingView.hidden = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    
    func stopLoadingVisual() {
        loadingView.hidden = true
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    
    
    
    
    
    
    
    // MARK: ===== MapView Methods =====
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CurrentUser {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.animatesDrop = true
            }
            return view
        }
        return nil
    }
    
    
    func updateMapView() {
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: currentUser.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(currentUser)
        mapView.selectAnnotation(mapView.annotations[0], animated: true)
    }
    
    
    
    
    
    
    
    // MARK: ===== GeoCode Methods =====
    
    func shouldGeocode() {
        if locationTextField.text != "" {
            forwardGeocoding(locationTextField.text!)
            startLoadingVisual()
        } else {
            presentAlert("Enter location", message: "Please enter a valid location")
        }
    }
    
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                self.presentAlert("No location found", message: "Please check the location entered")
                return
            }
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = placemarks[0]
                    if let location = placemark.location {
                        self.currentUser.title = placemark.name
                        let coordinate = location.coordinate
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.mapView.removeAnnotation(self.currentUser)
                        })
                        self.currentUser.coordinate = coordinate
                        dispatch_async(dispatch_get_main_queue(), {
                            self.stopLoadingVisual()
                            self.updateMapView()
                            self.mapView.hidden = false
                            self.whereAreYouStudyingLabel.hidden = true
                            self.locationTextField.hidden = true
                            self.findTheMapButton.hidden = true
                            self.submitButton.hidden = false
                            self.urlTextField.hidden = false
                            
                        })
                    }
                }
            }
        })
    }
    
    
    
    
    
    
    
    // MARK: ===== AlertView Method =====
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    // MARK: === TextField Delagate Methods ===
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        shouldGeocode()
        return true
    }
}
