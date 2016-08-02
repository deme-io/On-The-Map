//
//  UIViewControllerExtension.swift
//  On The Map
//
//  Created by Demetrius Henry on 8/1/16.
//  Copyright © 2016 Demetrius Henry. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}
