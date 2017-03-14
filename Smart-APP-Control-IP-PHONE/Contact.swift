//
//  Contact.swift
//  SmartPhone
//
//  Created by zhaocai wang on 07/02/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class Contact: NSObject {
    let contactName: String;
    let telephonyNumber: String;

    init(contactName: String, telephonyNumber: String) {
        self.contactName = contactName
        self.telephonyNumber = telephonyNumber
    }
}
