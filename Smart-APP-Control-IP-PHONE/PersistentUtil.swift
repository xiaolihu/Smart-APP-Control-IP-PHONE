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
    
    static func getCallHistory() -> Data? {
         return UserDefaults.standard.data(forKey: "CallHistoryKey")
    }
    
    static func addCallHistory(callHistory: CallHistory) {
//        if let arrayOfObjectsUnarchivedData = self.getCallHistory() {
//            var arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObject(with: arrayOfObjectsUnarchivedData) as! Array<CallHistory>
//            if arrayOfObjectsUnarchived.count > 0 {
//                arrayOfObjectsUnarchived.append(callHistory)
//            } else {
//                
//                callHistory.append(CallHistory(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890", callTime: Date()))
//                callHistory.append(CallHistory(contactName: "Javen Chen", telephonyNumber: "123-456-7891", callTime: Date()))
//            }
//            print(arrayOfObjectsUnarchived)
//        }
//        
//        if let arrayOfObjectsUnarchivedData = self.getCallHistory() {
//            let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObject(with: arrayOfObjectsUnarchivedData) as! Array<CallHistory>
//            if arrayOfObjectsUnarchived.count > 0 {
//                callHistory = arrayOfObjectsUnarchived
//            } else {
//                callHistory.append(CallHistory(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890", callTime: Date()))
//                callHistory.append(CallHistory(contactName: "Javen Chen", telephonyNumber: "123-456-7891", callTime: Date()))
//            }
//            print(arrayOfObjectsUnarchived)
//        } else {
//            callHistory.append(CallHistory(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890", callTime: Date()))
//            callHistory.append(CallHistory(contactName: "Javen Chen", telephonyNumber: "123-456-7891", callTime: Date()))
//        }
    }
}
