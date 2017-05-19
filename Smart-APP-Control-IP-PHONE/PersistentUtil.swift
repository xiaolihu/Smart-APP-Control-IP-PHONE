//
//  PersistentUtil.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by zhaocwan on 19/05/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation

class PersistentUtil {
    static func storeContactList(contactList : Array<Contact>) {
        let defaults = UserDefaults.standard
        let arrayOfObjectsKey = "ContactListKey"
        
        let arrayOfObjectsData = NSKeyedArchiver.archivedData(withRootObject: contactList)
        
        defaults.set(arrayOfObjectsData, forKey: arrayOfObjectsKey)
        defaults.synchronize()
    }
    
    static func storeCallHistory(callHistory : Array<CallHistory>) {
        let defaults = UserDefaults.standard
        let arrayOfObjectsKey = "CallHistoryKey"
        
        let arrayOfObjectsData = NSKeyedArchiver.archivedData(withRootObject: callHistory)
        
        defaults.set(arrayOfObjectsData, forKey: arrayOfObjectsKey)
        defaults.synchronize()
    }
}
