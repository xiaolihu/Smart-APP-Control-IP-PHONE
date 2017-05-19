//
//  CallHistory.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by zhaocwan on 19/05/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

class CallHistory: NSObject, NSCoding {
    
    let contactName: String;
    let telephonyNumber: String;
    let callTime: Date;
    
    init(contactName: String, telephonyNumber: String, callTime : Date) {
        self.contactName = contactName
        self.telephonyNumber = telephonyNumber
        self.callTime = callTime
    }
    
    required init(coder aDecoder: NSCoder) {
        contactName = aDecoder.decodeObject(forKey: "contactName") as! String
        telephonyNumber = aDecoder.decodeObject(forKey: "telephonyNumber") as! String
        callTime = aDecoder.decodeObject(forKey: "callTime") as! Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(contactName, forKey: "contactName")
        aCoder.encode(telephonyNumber, forKey: "telephonyNumber")
        aCoder.encode(callTime, forKey: "callTime")

    }
}
