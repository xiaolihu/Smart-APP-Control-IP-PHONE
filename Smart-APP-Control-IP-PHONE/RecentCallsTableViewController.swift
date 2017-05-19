//
//  RecentCallsTableViewController.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by zhaocwan on 19/05/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import Foundation
import UIKit

class RecentCallsTableViewController: UITableViewController {
    private var callHistory = Array<CallHistory>() {
        didSet {
            tableView.reloadData()
            PersistentUtil.storeCallHistory(callHistory: self.callHistory)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let arrayOfObjectsUnarchivedData = UserDefaults.standard.data(forKey: "CallHistoryKey") {
            let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObject(with: arrayOfObjectsUnarchivedData) as! Array<CallHistory>
            if arrayOfObjectsUnarchived.count > 0 {
                callHistory = arrayOfObjectsUnarchived
            } else {
                callHistory.append(CallHistory(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890", callTime: Date()))
                callHistory.append(CallHistory(contactName: "Javen Chen", telephonyNumber: "123-456-7891", callTime: Date()))
            }
            print(arrayOfObjectsUnarchived)
        } else {
            callHistory.append(CallHistory(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890", callTime: Date()))
            callHistory.append(CallHistory(contactName: "Javen Chen", telephonyNumber: "123-456-7891", callTime: Date()))
        }
        
        self.navigationItem.title = "Recent Calls"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return callHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistoryCell", for: indexPath)
        
        cell.textLabel?.text = callHistory[indexPath.row].contactName
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: callHistory[indexPath.row].callTime, dateStyle: .long, timeStyle: .none) + "\n" + DateFormatter.localizedString(from: callHistory[indexPath.row].callTime, dateStyle: .none, timeStyle: .short)
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContantName = callHistory[indexPath.row].contactName
        let selecteTelephonyNumber = callHistory[indexPath.row].telephonyNumber
        print(selectedContantName)
        print(selecteTelephonyNumber)
        
        if let vrc = self.navigationController?.viewControllers[0] as? VoiceRecognitionViewController {
            vrc.selectedContantName = selectedContantName
            vrc.selecteTelephonyNumber = selecteTelephonyNumber
            vrc.startCall()
            navigationController?.popViewController(animated: true)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            // Delete the row from the data source
            callHistory.remove(at: indexPath.row)
            print(indexPath.section)
            print(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
