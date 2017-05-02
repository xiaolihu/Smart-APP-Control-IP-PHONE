//
//  BTDiscovery.swift
//  ControlIPPhoneViaBLE
//
//  Created by Xiaolin Huang on 2/27/17.
//  Copyright © 2017 Xiaolin Huang. All rights reserved.
//

import Foundation
import CoreBluetooth

//let searchAllServicesUUID = CBUUID(string: nil)
// ************************ To implement the central role with iPhone **********
// 1. Start up a central manager object
// 2. Discover and connect to peripheral devices that are advertising
// 3. Explore the data on a peripheral device after you’ve connected to it
// 4. Send read and write requests to a characteristic value of a peripheral’s service
// 5. Subscribe to a characteristic’s value to be notified when it is updated


class BTDiscovery: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager?
    private var discoveredPeripheral: CBPeripheral?
    
    var gattBLEService: BTService? {
        didSet {
            gattBLEService?.startDiscoveringService()
        }
    }
    
    override init() {
        super.init()
        
        // create a queue ?
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralStartSanning() {
        print("Starting to scan for services !")
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // PS ********* CBCentralManagerDelegate **********
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("Discovering peripheral: \(peripheral), RSSI: \(RSSI), advData: \(advertisementData)!")
        if (peripheral.name == nil) {
            return
        }
        
        if (self.discoveredPeripheral == nil) {
            self.discoveredPeripheral = peripheral
        }
        
        print("Trying to connect peripheral !")
        if (self.discoveredPeripheral?.state == CBPeripheralState.disconnected) {
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //
        print("Connected to peripheral: \(peripheral) : \(peripheral.services)!")
        if (peripheral == self.discoveredPeripheral) {
            print ("Start to create services !")
            self.gattBLEService = BTService(initWithPeripheral: peripheral)
        }
        
        // after connected stop scanning for saving power
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        if (peripheral == self.discoveredPeripheral) {
            self.discoveredPeripheral = nil
            self.gattBLEService = nil
        }
        
        self.centralStartSanning()
    }
    
    func clearDevices() {
        self.gattBLEService = nil
        self.discoveredPeripheral = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Bluetooth Off !")
            self.clearDevices()
        case .poweredOn:
            print("Bluetooth on !")
            self.centralStartSanning()
        case .resetting:
            self.clearDevices()
        default:
            break
        }
    }
}
