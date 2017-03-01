//
//  KeyboardViewController.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by javchen on 1/3/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        textField.resignFirstResponder()
    }
}
