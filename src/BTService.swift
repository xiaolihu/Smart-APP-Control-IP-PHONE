//
//  BTService.swift
//  ControlIPPhoneViaBLE
//
//  Created by Xiaolin Huang on 2/27/17.
//  Copyright © 2017 Xiaolin Huang. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var speechTextCharacteristic: CBCharacteristic?
    var speechTextValue: Data?
    
    let uuidsForGATTCharacteristics: [CBUUID] = [speechTextCharacteristicUUID]
    
    init (initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        if peripheral != nil {
            peripheral = nil
        }
        
        // Also update Bluetooth disconnected status to UI
    }
    
    func startDiscoveringService() {
        self.peripheral?.discoverServices([localBLEServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?){
        if (peripheral != self.peripheral) {
            return
        }
        
        if (error != nil) {
            return
        }
        
        if (peripheral.services == nil || peripheral.services?.count == 0) {
            return
        }
        
        for service in peripheral.services! {
            if service.uuid == localBLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForGATTCharacteristics, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?){
        if (peripheral != self.peripheral) {
            return
        }
        
        if (error != nil) {
            return
        }
        
        // retrieve characteristics and subscribe it
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == speechTextCharacteristicUUID {
                    self.speechTextCharacteristic = characteristic
                    
                    peripheral.readValue(for: characteristic)
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    self.updateBluetoothConnectionStatus()
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?){
        if (peripheral != self.peripheral) {
            return
        }
        
        if (error != nil) {
            return
        }
        
        if (characteristic.value != nil) {
            self.speechTextValue = characteristic.value
        }
    }
    
    func updateBluetoothConnectionStatus () {
        // send 'Connected' or 'Disconnected' to view controller
    }
}
