//
//  BTAdvertise.swift
//  ControlIPPhoneViaBLE
//
//  Created by Xiaolin Huang on 2/27/17.
//  Copyright © 2017 Xiaolin Huang. All rights reserved.
//

import Foundation
import CoreBluetooth

let localBLEServiceUUID = CBUUID(string: "55A65D57-B27C-4C7A-ADAA-6C6DE5813B04")
let speechTextCharacteristicUUID = CBUUID(string: "534C89ED-19D1-4DA7-9572-DE9FED4A5FFD")

// *********** Setting up iPhone as Peripheral ************
// 1. Start up a peripheral manager object
// 2. Set up services and characteristics on your local peripheral
// 3. Publish your services and characteristics to your device’s local database
// 4. Advertise your services
// 5. Respond to read and write requests from a connected central
// 6. Send updated characteristic values to subscribed centrals


class BTAdvertise: NSObject, CBPeripheralManagerDelegate {
    // Start up a peripheral manager object
    var peripheralMgr: CBPeripheralManager?
    // Set up characteristics 
    var speechTextCharacteristic: CBMutableCharacteristic
    // init value of characteristics
    var speechTextValue: Data? = nil  // who update it ? Speech Recognition (ASR) module ?
    //
    var peripheralService: CBMutableService?
    
    private let advertiseData: Dictionary<String, CBUUID>= [
        "iPhone as Peripheral": speechTextCharacteristicUUID
    ]
    
    override init(){
        self.speechTextCharacteristic = CBMutableCharacteristic.init(type: speechTextCharacteristicUUID, properties: CBCharacteristicProperties.write, value: speechTextValue, permissions: CBAttributePermissions.writeable)
        
        self.peripheralService = CBMutableService.init(type: localBLEServiceUUID, primary: true)
        peripheralService?.characteristics = [speechTextCharacteristic]
        
        super.init()
        self.peripheralMgr = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    
    private func publishPeripheralService() {
        self.peripheralMgr?.add(self.peripheralService!)
    }
    
    private func removePeripheralService () {
        self.peripheralMgr?.remove(self.peripheralService!)
    }
    
    // let server role discover our iPhone
    private func startPeripheralAdvertising () {
        self.peripheralMgr?.startAdvertising(self.advertiseData)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if((error) != nil) {
           print("Failed to publish service \(error) !")
           return
        }
        
        if(peripheral != self.peripheralMgr) {
            print("wrong peripheralMgr")
            return
        }
        
        if(service.characteristics == nil) {
            return
        }
    }

    // PS ************ CBPeripheralManagerDelegate ***********
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,
                                              error: Error?){
        if((error) != nil) {
            print("Failed to start advertising \(error)!")
        }
    }

    // send Speech 'Text' to IP PHONE
    func peripheralManager(_ peripheralMgr: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        
        if (peripheralMgr != self.peripheralMgr) {
            peripheralMgr.respond(to: request, withResult: CBATTError.requestNotSupported)
            return
        }
        
        if (request.characteristic.uuid == speechTextCharacteristic.uuid) {
            if(request.offset > (speechTextCharacteristic.value?.endIndex)!){
                peripheralMgr.respond(to: request, withResult: CBATTError.invalidOffset)
                print("Wrong Offset !")
            } else {
                request.value = speechTextCharacteristic.value
            }
            
            peripheralMgr.respond(to: request, withResult: CBATTError.success)
        } else {
            peripheralMgr.respond(to: request, withResult: CBATTError.attributeNotFound)
            print("Wrong Read Request !")
            return
        }
    }
    
    // a draft implementation
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveWrite requests: [CBATTRequest]){
        
        if (requests.first?.characteristic.uuid == speechTextCharacteristic.uuid) {
            speechTextCharacteristic.value = requests.first?.characteristic.value
            peripheralMgr?.respond(to: requests.first!, withResult: CBATTError.success)
        } else {
            print("Wrong Write Request !")
        }
    }
    
    // accept a subscription
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic){
        
        let didSendValue = peripheral.updateValue(speechTextCharacteristic.value!, for: characteristic as! CBMutableCharacteristic , onSubscribedCentrals: nil)
        if(didSendValue) {
            print("update value successfully")
        }
    }

    func peripheralManagerDidUpdateState(_ peripheralMgr: CBPeripheralManager){
        print("Status of CBPeripheralManager is : \(peripheralMgr.state) ")
        switch peripheralMgr.state {
        case .poweredOn:// This state indicates that the central/peripheral device (your iPhone or iPad, for instance) supports
                        // Bluetooth low energy and that Bluetooth is on and available to use.
            print("Bluetooth Power On!")
            self.publishPeripheralService()
            self.startPeripheralAdvertising()
            break
        case .poweredOff:
            print("Bluetooth Power Off!")
            self.peripheralMgr?.stopAdvertising()
            self.removePeripheralService()
            break
        default:
            break
        }
    }
    
}
