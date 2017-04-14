//
//  Contact.swift
//  SmartPhone
//
//  Created by zhaocai wang on 07/02/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class Contact: NSObject, NSCoding {
    let contactName: String;
    let telephonyNumber: String;

    init(contactName: String, telephonyNumber: String) {
        self.contactName = contactName
        self.telephonyNumber = telephonyNumber
    }
    
    required init(coder aDecoder: NSCoder) {
        contactName = aDecoder.decodeObject(forKey: "contactName") as! String
        telephonyNumber = aDecoder.decodeObject(forKey: "telephonyNumber") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(contactName, forKey: "contactName")
        aCoder.encode(telephonyNumber, forKey: "telephonyNumber")
    }
}
