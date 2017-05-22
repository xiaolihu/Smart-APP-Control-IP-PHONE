//
//  ContactListTableViewController.swift
//  SmartPhone
//
//  Created by zhaocai wang on 07/02/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    private var contactList = Array<Contact>() {
        didSet {
            tableView.reloadData()
            PersistentUtil.storeContactList(contactList: self.contactList)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let arrayOfObjectsUnarchivedData = PersistentUtil.getContactList() {
            let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObject(with: arrayOfObjectsUnarchivedData) as! Array<Contact>
            if arrayOfObjectsUnarchived.count > 0 {
                contactList = arrayOfObjectsUnarchived
            } else {
                contactList.append(Contact(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890"))
                contactList.append(Contact(contactName: "Javen Chen", telephonyNumber: "123-456-7891"))
            }
            print(arrayOfObjectsUnarchived)
        } else {
            contactList.append(Contact(contactName: "Zhaocai Wang", telephonyNumber: "123-456-7890"))
            contactList.append(Contact(contactName: "Javen Chen", telephonyNumber: "123-456-7891"))
        }
        
        self.navigationItem.title = "Contact List"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contactList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        
        cell.textLabel?.text = contactList[indexPath.row].contactName
        cell.detailTextLabel?.text = contactList[indexPath.row].telephonyNumber
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
        let selectedContantName = contactList[indexPath.row].contactName
        let selecteTelephonyNumber = contactList[indexPath.row].telephonyNumber
        // print(selectedContantName)
        // print(selecteTelephonyNumber)
        
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
            contactList.remove(at: indexPath.row)
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
    
    @IBAction func AddContact(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Contact", message: "Please add contact name and phone number", preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel)
        { (action: UIAlertAction) -> Void in
            // do nothing
            }
        )
        alert.addAction(UIAlertAction(
            title: "Save",
            style: .default)
        { (action: UIAlertAction) -> Void in
            // get password and log in
            if let tf = alert.textFields  {                          // Alert中输入
                if let cn = tf[0].text, !cn.isEmpty {
                    let pn = tf[1].text
                    self.contactList.append(Contact(contactName: cn, telephonyNumber: pn!))
                }
            }
            }
        )
        alert.addTextField { (textField) in               // Alert中输入框
            textField.placeholder = "Contact Name"
        }
        alert.addTextField { (textField) in               // Alert中输入框
            textField.placeholder = "Phone Number"
        }
        present(alert, animated: true, completion: nil)
    }  
}
