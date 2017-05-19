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
    
    static func getContactList() -> Data? {
        return UserDefaults.standard.data(forKey: "ContactListKey")
    }
    
    static func storeCallHistory(callHistory : Array<CallHistory>) {
        let defaults = UserDefaults.standard
        let arrayOfObjectsKey = "CallHistoryKey"
        
        let arrayOfObjectsData = NSKeyedArchiver.archivedData(withRootObject: callHistory)
        
        defaults.set(arrayOfObjectsData, forKey: arrayOfObjectsKey)
        defaults.synchronize()
    }
    
    static func getCallHistory() -> Array<CallHistory> {
        var callHistoryList : Array<CallHistory>
        if let arrayOfObjectsUnarchivedData = UserDefaults.standard.data(forKey: "CallHistoryKey") {
            let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObject(with: arrayOfObjectsUnarchivedData) as! Array<CallHistory>
            if arrayOfObjectsUnarchived.count > 0 {
                callHistoryList = arrayOfObjectsUnarchived
            } else {
                callHistoryList = Array<CallHistory>()
            }
        } else {
            callHistoryList = Array<CallHistory>()
        }
        
        return callHistoryList;
    }
    
    static func addCallHistory(callHistory: CallHistory) {
        var callHistoryList = self.getCallHistory()
                callHistoryList.append(callHistory)
        self.storeCallHistory(callHistory:callHistoryList)
    }
}
