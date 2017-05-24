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
    private var callHistoryList = Array<CallHistory>() {
        didSet {
            tableView.reloadData()
            PersistentUtil.storeCallHistory(callHistory: self.callHistoryList)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if PersistentUtil.getCallHistory().count > 0 {
            callHistoryList = PersistentUtil.getCallHistory()
        } else {
            callHistoryList.append(CallHistory(contactName: "Wang Zhaocai", telephonyNumber: "88911495", callTime: Date()))
            callHistoryList.append(CallHistory(contactName: "Chen Javen", telephonyNumber: "24224131", callTime: Date()))
        }
//        callHistoryList.removeAll()
//                PersistentUtil.addCallHistory(callHistory: CallHistory(contactName: "Javen Chen1", telephonyNumber: "123-456-7892", callTime: Date()))
        
        self.navigationItem.title = "Recent Calls"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return callHistoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistoryListCell", for: indexPath)
        
        cell.textLabel?.text = callHistoryList[indexPath.row].contactName
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: callHistoryList[indexPath.row].callTime, dateStyle: .long, timeStyle: .none) + "\n" + DateFormatter.localizedString(from: callHistoryList[indexPath.row].callTime, dateStyle: .none, timeStyle: .short)
      
        
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
        let selectedContantName = callHistoryList[indexPath.row].contactName
        let selecteTelephonyNumber = callHistoryList[indexPath.row].telephonyNumber
        // print(selectedContantName)
        // print(selecteTelephonyNumber)
        
        if let vrc = self.navigationController?.viewControllers[0] as? VoiceRecognitionViewController {
            vrc.selectedContantName = selectedContantName
            vrc.selecteTelephonyNumber = selecteTelephonyNumber
            vrc.startCall()
            navigationController?.popViewController(animated: true)
        }
    }
        /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            // Delete the row from the data source
            callHistoryList.remove(at: indexPath.row)
            print(indexPath.section)
            print(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    

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
